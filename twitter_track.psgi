#!perl
use strict;
use lib './lib';
use TwitterTrack;

if ($0 eq __FILE__) {
    require Plack::Runner;
    my $app = Plack::Runner->new;
    $app->parse_options(@ARGV);
    return $app->run(TwitterTrack->webapp);
}

TwitterTrack->webapp;


