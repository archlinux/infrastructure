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
my @nginx_log_file_paths = glob("/var/log/nginx/*-access.log /var/log/nginx/*/access.log");
my $hostname_regex = qr/^.*(archlinux\.org|pkgbuild\.com)$/;

@nginx_log_file_paths = ("./test-access.log") if $devmode;

my $logfile;

#$SIG{PIPE} = 'IGNORE';
$SIG{__DIE__} = sub {
	print STDERR "Should be dying now\n";
	#close $logfile;
	POSIX::_exit(2);
	print STDERR "Called exit()\n";
};

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
	my $ret = syswrite $zabbix_sender, (sprintf "- %s %s\n", $key, $value);
	if (not defined $ret) {
		print STDERR "Writing failed: '$!' Restarting zabbix_sender\n";
		undef $zabbix_sender;
		send_zabbix(@_);
	}
}

sub main {
	die "No log files found" if @nginx_log_file_paths == 0;

	open $logfile, "-|", qw(tail -n0 -q -F), @nginx_log_file_paths;

	my $last_send_time = 0;
	my $value_template = {
		# counters since prog start
		status => {
			200 => 0,
			404 => 0,
			500 => 0,
			502 => 0,
			504 => 0,
			other => 0,
		},
		# counter since prog start
		request_count => 0,
		cached_request_count => 0,
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

		# json log format
		if ($line =~ m/^{.*}$/) {
			update_stats_for_line($values_per_host, $stat_per_host, $value_template, \$modified_hostlist, decode_json($line));
		}

		# main log format
		if ($line =~ m/(?<remote_addr>\S+) (?<host>\S+) (?<remote_user>\S+) \[(?<time_local>.*?)\]\s+"(?<request>.*?)" (?<status>\S+) (?<body_bytes_sent>\S+) "(?<http_referer>.*?)" "(?<http_user_agent>.*?)" "(?<http_x_forwarded_for>\S+)"(?: (?<request_time>[\d\.]+|-))?/) {
			update_stats_for_line($values_per_host, $stat_per_host, $value_template, \$modified_hostlist, \%+);
		}

		# reduced log format
		if ($line =~ m/(?<host>\S+) \[(?<time_local>.*?)\]\s+"(?<request>.*?)" (?<status>\S+) (?<body_bytes_sent>\S+) "(?<http_referer>.*?)" "(?<http_user_agent>.*?)"/) {
			update_stats_for_line($values_per_host, $stat_per_host, $value_template, \$modified_hostlist, \%+);
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

sub update_stats_for_line {
	my ($values_per_host, $stat_per_host, $value_template, $modified_hostlist, $line_values) = @_;

	my %val = %$line_values;
	my $host = $val{host};

	return unless $host =~ m/$hostname_regex/;

	if (not defined $values_per_host->{$host}) {
		$values_per_host->{$host} = clone($value_template);
		$stat_per_host->{$host} = Statistics::Descriptive::Full->new();
		$$modified_hostlist = 1;
	}

	my $stat = $stat_per_host->{$host};
	my $values = $values_per_host->{$host};

	$stat->add_data($val{request_time}) if defined($val{request_time}) and $val{request_time} != 0;
	$values->{request_count}++;
	$values->{cached_request_count}++ if defined($val{request_time}) and $val{request_time} == 0;

	my $status_key = defined $values->{status}->{$val{status}} ? $val{status} : "other";
	$values->{status}->{$status_key}++;
}

main();
