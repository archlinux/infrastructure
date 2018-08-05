#!/usr/bin/env perl
use strict;
use warnings;

use Config::Simple;
use Data::Dumper;
use MediaWiki::API;

die "Missing required argument (config file path)" if @ARGV == 0;

my $config = Config::Simple->new($ARGV[0]) or die Config::Simple->error();

my $mw = MediaWiki::API->new({api_url => 'https://wiki.archlinux.org/api.php'});

$mw->login( { lgname => $config->param('bot_credentials.username'), lgpassword => $config->param('bot_credentials.password') } )
  || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};


my $stdin = do { local $/; <STDIN> };

my $reply = $mw->api({
		action => "bouncehandler",
		email => $stdin,
	}) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};;

# output reply in case of error. doc doesn't say what the replies are so we just output everything for now
warn Dumper($reply);

