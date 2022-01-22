use warnings;
use strict;
use Test::More;

use App::SpamcupNG::Summary;
my $instance = new_ok('App::SpamcupNG::Summary');
can_ok( $instance, qw(new as_text) );
is( $instance->as_text,
    'id=not available,mailer=not available,content_type=not available,age=not available,age_unit=not available,receivers=(),contacts=()',
    'as_text returns the expected empty instance'
    );
ok( $instance->set_id('123456'),            'set ID' );
ok( $instance->set_mailer('Foobar Mailer'), 'set mailer' );
ok( $instance->set_content_type('text/plain;charset=utf-8'),
    'set content type' );
ok( $instance->set_age(2),           'set age' );
ok( $instance->set_age_unit('hour'), 'set age unit' );
my $emails_ref = [ 'john@gmail.com', 'doe@gmail.com' ];
ok( $instance->set_receivers($emails_ref), 'set receivers' );
ok( $instance->set_contacts($emails_ref),  'set contacts' );
is( $instance->as_text,
    'id=123456,mailer=Foobar Mailer,content_type=text/plain;charset=utf-8,age=2,age_unit=hour,receivers=(john@gmail.com;doe@gmail.com),contacts=(john@gmail.com;doe@gmail.com)',
    'as_text returns the expected string'
    );

done_testing;

# vim: filetype=perl

