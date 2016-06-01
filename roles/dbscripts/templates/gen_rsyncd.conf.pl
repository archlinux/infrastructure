#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Data::Dumper;

# TODO put these into credentials.ini and use Config::Simple to read it
my $user = 'archweb_rsync';
my $pass = '{{ postgres_users.archweb_rsync }}';
my $db = 'DBI:Pg:dbname=archweb;host=gudrun.archlinux.org;sslmode=require';

my $scriptdir="/etc/rsyncd-conf-genscripts";
my $infile="$scriptdir/rsyncd.conf.proto";
my $outfile="/etc/rsyncd.conf";

my $query = 'SELECT mrs.ip FROM mirrors_mirrorrsync mrs LEFT JOIN mirrors_mirror m ON mrs.mirror_id = m.id WHERE tier = 1 ORDER BY ip';

sub burp {
	my ($file_name, @lines) = @_;
	open (my $fh, ">", $file_name) || die sprintf(gettext("can't create '%s': %s"), $file_name, $!);
	print $fh @lines;
	close $fh;
}

my $dbh = DBI->connect($db, $user, $pass);
my $sth = $dbh->prepare($query);

$sth->execute;

$sth->rows > 0 or die "Failed to fetch IPs";

my @whitelist_ips;
while (my @ipaddr = $sth->fetchrow_array) {
	push @whitelist_ips, $ipaddr[0]
}

$dbh->disconnect;

open (my $fh, "<", $infile) or die "Failed to open '$infile': $!";
my @data = <$fh>;
close $fh;

my $tier1_whitelist = join " ", @whitelist_ips;
for (@data) {
	s|\@\@ALLOWHOSTS_TIER1@@|$tier1_whitelist|;
}

burp($outfile, @data);
