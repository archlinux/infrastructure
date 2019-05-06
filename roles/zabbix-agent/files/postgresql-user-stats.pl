#!/usr/bin/env perl
use strict;
use warnings;

use DBI;
use JSON;

my $mode = $ARGV[0];
my $dbname = $ARGV[1];

if (!($mode eq "userstat" or $mode eq "discover")) {
	print STDERR "mode is not userstat or discover\n";
	die;
}

if ($mode eq "userstat" and not defined $dbname) {
	print STDERR "userstat requires dbname to be defined\n";
	die;
}

my $db = DBI->connect("DBI:Pg:");

if ($mode eq "userstat") {
	print encode_json($db->selectrow_hashref("SELECT tup_fetched,tup_returned,tup_inserted,tup_deleted,tup_updated,deadlocks,blks_hit,blks_read from pg_stat_database where datname = ?;", undef, $dbname));
} elsif ($mode eq "discover") {
	print encode_json({
		data => $db->selectall_arrayref("SELECT datname \"{#DATNAME}\" FROM pg_database;", {Slice => {}})
	});
} else {
	die "unhandled mode";
}
