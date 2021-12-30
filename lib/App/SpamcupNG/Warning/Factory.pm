package App::SpamcupNG::Warning::Factory;
use strict;
use warnings;
use Exporter 'import';

use App::SpamcupNG::Warning;
use App::SpamcupNG::Warning::Yum;

# VERSION

our @EXPORT_OK = qw(create_warning);

my $yum_regex = qr/^Yum/;

sub create_warning {
    my $message_ref = shift;

    die 'message must be an array reference'
        unless ( ( ref($message_ref) eq 'ARRAY' )
        and ( scalar( @{$message_ref} ) > 0 ) );

    return App::SpamcupNG::Warning::Yum->new($message_ref)
        if ( $message_ref->[0] =~ $yum_regex );
    return App::SpamcupNG::Warning->new($message_ref);
}

1;
