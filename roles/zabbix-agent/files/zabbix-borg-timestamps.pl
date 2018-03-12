#!/usr/bin/env perl
use strict;
use warnings;

use autodie;
use JSON::XS;
use POSIX;

my $json = decode_json(`/usr/local/bin/borg list --json --format '{start}{end}' --sort-by timestamp --last 1`);
print encode_json({
		last_archive => {
			is_checkpoint => $json->{archives}[0]->{archive} =~ m/.checkpoint$/ ? 1 : 0,
			start => parse_time($json->{archives}[0]->{start}),
			end => parse_time($json->{archives}[0]->{end}),
			age => time() - parse_time($json->{archives}[0]->{end}),
		},
		repository => {
			last_modified => parse_time($json->{repository}->{last_modified}),
		},
});

sub parse_time {
	my ($string) = @_;

    if ($string =~ m/^(?<year>....)-(?<month>..)-(?<day>..)T(?<hour>..):(?<minute>..):(?<second>..)(?:\.\d+)?$/) {
        my $time = POSIX::mktime($+{second},$+{minute},$+{hour},$+{day},$+{month}-1,$+{year}-1900);
        return $time;
    }
	# return undef to ensure that the value is set in the json
    return undef;
}
