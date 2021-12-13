package App::SpamcupNG::Error::Bounce;
use strict;
use warnings;
use parent 'App::SpamcupNG::Error';

sub new {
    my ( $class, $message_ref ) = @_;
    return $class->SUPER::new( $message_ref, 1 );
}

sub message {
    my $self = shift;
    my @temp = @{ $self->{message} };
    $temp[0] =~ s/\:$/,/;
    $temp[1] .= ',';
    $temp[2] .= '.';
    $temp[3]
        = 'Please, access manually the Spamcop website and fix this before trying to run spamcup again.';
    return join( ' ', @temp );
}

1;
