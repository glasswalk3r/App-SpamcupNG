package App::SpamcupNG::Error;
use strict;
use warnings;

# VERSION

sub new {
    my ( $class, $message_ref, $is_fatal ) = @_;
    $is_fatal //= 0;

    die 'message must be an no empty array reference'
        unless ( ( ref($message_ref) eq 'ARRAY' )
        and ( scalar( @{$message_ref} ) > 0 ) );

    for ( my $i = 0; $i < scalar( @{$message_ref} ); $i++ ) {
        $message_ref->[$i] =~ s/^\s+//;
        $message_ref->[$i] =~ s/\s+$//;
    }

    my $self = {
        message  => $message_ref,
        is_fatal => $is_fatal
        };

    bless( $self, $class );
    return $self;
}

sub message {
    my $self = shift;
    return $self->{message}->[0];
}

sub is_fatal {
    my $self = shift;
    return $self->{is_fatal};
}

1;
