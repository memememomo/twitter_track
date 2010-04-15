package TwitterTrack;

use strict;
use 5.008_001;
our $VERSION = '0.01';

use Tatsumaki::Application;
use Tatsumaki::Handler;


sub h($) {
    my $class = shift;
    eval "require $class" or die $@;
    $class;
}


sub webapp {
    my $class = shift;
    
    my $word = '[\w\.\-]+';
    my $app = Tatsumaki::Application->new([
	"/($word)/poll/" => h 'TwitterTrack::Handler::Stream::Tweet',
	"/($word)" => h 'TwitterTrack::Handler::Html',
					  ]);
    $app->template_path( "root/template" );
    $app->static_path( "root/static" );

    $app->psgi_app;
}

1;

