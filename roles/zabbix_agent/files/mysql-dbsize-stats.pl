#!/usr/bin/env perl
use strict;
use warnings;

use DBI;
use JSON;

my $config = $ARGV[0];
my $mode = $ARGV[1];
my $dbname = $ARGV[2];

if (!($mode eq "dbsize" or $mode eq "discover")) {
	print STDERR "mode is not dbsize or discover\n";
	die;
}

if ($mode eq "dbsize" and not defined $dbname) {
	print STDERR "dbsize requires dbname to be defined\n";
	die;
}

my $db = DBI->connect("DBI:mysql:mysql_read_default_file=$config");

if ($mode eq "dbsize") {
	print encode_json($db->selectrow_hashref("select SUM(ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024 ), 2)) AS dbsize from information_schema.tables where table_schema = ?", undef, $dbname));
} elsif ($mode eq "discover") {
	print encode_json({
		data => $db->selectall_arrayref("SELECT table_schema '{#TABLE_SCHEMA}' FROM information_schema.tables GROUP BY table_schema;", {Slice => {}})
	});
} else {
	die "unhandeled mode";
}
