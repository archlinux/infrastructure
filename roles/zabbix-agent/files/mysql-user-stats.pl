#!/usr/bin/env perl
use strict;
use warnings;

use DBI;
use JSON;

my $config = $ARGV[0];
my $mode = $ARGV[1];
my $user = $ARGV[2];

if (!($mode eq "userstat" or $mode eq "discover")) {
	print STDERR "mode is not userstat or discover\n";
	die;
}

if ($mode eq "userstat" and not defined $user) {
	print STDERR "userstat requires user to be defined\n";
	die;
}

my $db = DBI->connect("DBI:mysql:mysql_read_default_file=$config");

if ($mode eq "userstat") {
	$db->{FetchHashKeyName} = "NAME_lc";
	print encode_json($db->selectrow_hashref("select * from information_schema.user_statistics where user = ?", undef, $user));
} elsif ($mode eq "discover") {
	print encode_json({
			data=> [
				$db->selectall_arrayref("select user '#USERNAME' from information_schema.user_statistics", {Slice=>{}})
			]
		});
} else {
	die "unhandeled mode";
}
