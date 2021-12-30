package App::SpamcupNG::Warning;
use strict;
use warnings;

# VERSION

sub new {
    my ( $class, $message_ref ) = @_;

    die 'message is a required parameter'
        unless ( ( ref($message_ref) eq 'ARRAY' )
        and ( scalar($message_ref) > 0 ) );

    my @trimmed;

    foreach my $msg ( @{$message_ref} ) {
        $msg =~ s/^\s+//;
        $msg =~ s/(\s+)?\.?$//;
        push( @trimmed, $msg );
    }

    my $self = { message => \@trimmed };
    bless( $self, $class );
    return $self;
}

sub message {
    my $self = shift;
    return join( '. ', @{ $self->{message} } ) . '.';
}

1;
