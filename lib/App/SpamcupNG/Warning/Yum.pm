package App::SpamcupNG::Warning::Yum;
use strict;
use warnings;
use parent 'App::SpamcupNG::Warning';

sub new {
    my ( $class, $messages_ref ) = @_;
    my $self = $class->SUPER::new( [ $messages_ref->[0] ] );
    return $self;
}

sub message {
    my $self = shift;
    return $self->{message}->[0];
}

1;
