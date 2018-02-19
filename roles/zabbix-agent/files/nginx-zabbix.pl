#!/usr/bin/env perl
use strict;
use warnings;

use v5.16;

use autodie;
use Clone 'clone';
use IO::Handle;
use JSON;
use Statistics::Descriptive;
use Time::HiRes qw(time sleep);

my $interval = 30;
my $devmode = 0;
my @nginx_log_file_paths = glob("/var/log/nginx/*-access.log");

@nginx_log_file_paths = ("./test-access.log") if $devmode;

sub trim {
	my $str = shift;
	$str =~ s/^\s+//;
	$str =~ s/\s+$//;
	return $str;
}

sub send_zabbix {
	my ($key, $value) = @_;
	state $zabbix_sender;
	if (not defined $zabbix_sender) {
		open $zabbix_sender, "|-", "zabbix_sender -c /etc/zabbix/zabbix_agentd.conf --real-time -i - >/dev/null" unless $devmode;
		open $zabbix_sender, "|-", "cat" if $devmode;
		$zabbix_sender->autoflush();
	}
	printf $zabbix_sender "- %s %s\n", $key, $value;
}

sub main {
	die "No log files found" if @nginx_log_file_paths == 0;

	open my $logfile, "-|", qw(tail -n0 -q -F), @nginx_log_file_paths;

	my $last_send_time = 0;
	my $value_template = {
		# counters since prog start
		status => {
			200 => 0,
			404 => 0,
			500 => 0,
			other => 0,
		},
		# counter since prog start
		request_count => 0,
		# calculated values since last send
		request_time => {
			max => 0,
			average => 0,
			median => 0,
		}
	};
	my $values_per_host = {};
	my $stat_per_host = {};
	my $modified_hostlist = 0;


	while (my $line = <$logfile>) {
		#print "Got line: ".$line."\n";
		$line = trim($line);

		if ($line =~ m/(?<remote_addr>\S+) (?<host>\S+) (?<remote_user>\S+) \[(?<time_local>.*?)\]\s+"(?<request>.*?)" (?<status>\S+) (?<body_bytes_sent>\S+) "(?<http_referer>.*?)" "(?<http_user_agent>.*?)" "(?<http_x_forwarded_for>\S+)"(?: (?<request_time>[\d\.]+|-))?/) {
			my $host = $+{host};

			if (not defined $values_per_host->{$host}) {
				$values_per_host->{$host} = clone($value_template);
				$stat_per_host->{$host} = Statistics::Descriptive::Full->new();
				$modified_hostlist = 1;
			}

			my $stat = $stat_per_host->{$host};
			my $values = $values_per_host->{$host};

			$stat->add_data($+{request_time});
			$values->{request_count}++;

			my $status_key = defined $values->{status}->{$+{status}} ? $+{status} : "other";
			$values->{status}->{$status_key}++;
		}

		my $now = time;

		if ($now >= $last_send_time + $interval) {
			send_zabbix('nginx.discover', encode_json({data => [ map { { "{#VHOSTNAME}" => $_ } } keys %{$values_per_host} ]})) if $modified_hostlist;
			$modified_hostlist = 0;

			for my $host (keys %{$values_per_host}) {
				my $stat = $stat_per_host->{$host};
				my $values = $values_per_host->{$host};

				$values->{request_time}->{max} = $stat->max() // 0.0;
				$values->{request_time}->{average} = $stat->mean() // 0.0;
				$values->{request_time}->{median} = $stat->median() // 0.0;

				if ($stat->count() == 0) {
					print STDERR "clearing stats for '$host'\n" if $devmode;
					delete $values_per_host->{$host};
					delete $stat_per_host->{$host};
					$modified_hostlist = 1;
				}
				$stat->clear();

				send_zabbix(sprintf('nginx.values[%s]', $host), encode_json($values));

			}
			$last_send_time = $now;
		}
	}
}

main();
