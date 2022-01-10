use warnings;
use strict;
use Test::More;
use Test::Exception;

use App::SpamcupNG::UserAgent;

my $instance
    = new_ok( 'App::SpamcupNG::UserAgent' => ['0.1.0'], 'new instance' );
my @expected_attribs
    = qw(name version members_url code_login_url report_url current_base_url user_agent);

foreach my $expected (@expected_attribs) {
    ok( exists( $instance->{$expected} ),
        "the instance has an attribute $expected"
        );
}

is( $instance->base(), undef, 'base URL is undefined' );
isa_ok( $instance->{user_agent}, 'LWP::UserAgent', 'user_agent attribute' );
my @expected_methods = qw(login spam_report base complete_report user_agent);
can_ok( $instance, @expected_methods );
is( $instance->user_agent,
    'spamcup user agent/0.1.0',
    'user_agent returns the proper string'
    );
dies_ok { App::SpamcupNG::UserAgent->new } 'dies with missing parameter';
like $@, qr/version\sis\srequired/;

done_testing;

# vim: filetype=perl
