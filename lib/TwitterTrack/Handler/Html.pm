package TwitterTrack::Handler::Html;
use Moose;

extends 'Tatsumaki::Handler';

sub get {
    my $self = shift;
    my ( $track ) = @_;
    $self->render( 'index.html' );
}

no Moose;

1;
