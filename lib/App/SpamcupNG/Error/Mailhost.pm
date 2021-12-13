package App::SpamcupNG::Error::Mailhost;
use strict;
use warnings;
use parent 'App::SpamcupNG::Error';

sub new {
    my ( $class, $message_ref ) = @_;
    die 'message must be an array reference with size = 3'
        unless ( ( ref($message_ref) eq 'ARRAY' )
        and ( scalar( @{$message_ref} ) == 3 ) );

    return $class->SUPER::new($message_ref);
}

sub message {
    my $self = shift;
    my @temp = @{ $self->{message} };
    $temp[0] = $temp[0] . '.';
    $temp[2] = lc( $temp[2] ) . '.';
    return join( ' ', @temp );
}

1;
