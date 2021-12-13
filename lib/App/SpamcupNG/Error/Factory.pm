package App::SpamcupNG::Error::Factory;
use strict;
use warnings;
use Exporter 'import';

use App::SpamcupNG::Error;
use App::SpamcupNG::Error::Mailhost;
use App::SpamcupNG::Error::Bounce;

our @EXPORT_OK = qw(create_error);

my $mailhost_regex = qr/Mailhost\sconfiguration\sproblem/;
my $bounce_regex   = qr/bounce/;
my @fatal_errors   = ( qr/email\sis\stoo\sold/, qr/^Nothing/ );

sub create_error {
    my ( $message_ref, $is_fatal ) = @_;
    $is_fatal //= 0;

    die 'message must be an no empty array reference'
        unless ( ( ref($message_ref) eq 'ARRAY' )
        and ( scalar( @{$message_ref} ) > 0 ) );

    return App::SpamcupNG::Error::Mailhost->new($message_ref)
        if ( $message_ref->[0] =~ $mailhost_regex );

    return App::SpamcupNG::Error::Bounce->new( $message_ref, 1 )
        if ( $message_ref->[0] =~ $bounce_regex );

    return App::SpamcupNG::Error->new( $message_ref, $is_fatal )
        if ($is_fatal);

    foreach my $regex (@fatal_errors) {
        if ( $message_ref->[0] =~ $regex ) {
            $is_fatal = 1;
            last;
        }
    }

    return App::SpamcupNG::Error->new( $message_ref, $is_fatal );
}
