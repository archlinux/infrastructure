#!/usr/bin/env perl
use strict;
use warnings;

use DBI;
use JSON;

my $config = $ARGV[0] // "$ENV{HOME}/.my.cnf";

my $db = DBI->connect("DBI:mysql:mysql_read_default_file=$config");
$db->{FetchHashKeyName} = "NAME_lc";
print encode_json($db->selectall_hashref("select * from information_schema.user_statistics", "user"));
