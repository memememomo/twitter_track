package TwitterTrack::Handler::Stream::Tweet;

use Moose;
use Config::Pit;
use AnyEvent::Twitter::Stream;
use Tatsumaki::MessageQueue;
use Tatsumaki::Error;

extends 'Tatsumaki::Handler';
__PACKAGE__->asynchronous(1);


my ($username, $password) = do {
    @{ Config::Pit::get( 'twitter.com', require => {
	'username' => 'memememomo',
			 })}{ qw/username password/ };
};

my %streams;

sub create_stream {
    my $self = shift;
    my ( $track ) = @_;

    my $mq = Tatsumaki::MessageQueue->instance( $track );
    $streams{$track} ||= AnyEvent::Twitter::Stream->new(
	username => $username,
	password => $password,
	method => 'filter',
	track => $track,
	on_tweet => sub {
	    my $tweet = shift;
	    $mq->publish( { type => 'tweet', tweet => $tweet, } );
	},
	on_error => sub {
	    my $error = join ',', @_;
	    $mq->publish( { type => 'message', text => $error, } );
	    delete $streams{ $track };
	},
	on_eof => sub {
	    $mq->publish( { type => 'message', text => 'disconnected', } );
	    delete $streams{ $track };
	},
	);
}


sub get {
    my $self = shift;
    my ( $track ) = @_;

    my $session = $self->request->param('session')
	or Tatsumaki::Error::HTTP->throw(500, "'session' needed");

    $streams{ $track } or $self->create_stream( $track );
    my $mq = Tatsumaki::MessageQueue->instance( $track );
    $mq->poll_once( $session, sub {
	my @events_published = @_;
	$self->write( \@events_published );
	$self->finish;
		    });
}

no Moose;

1;
