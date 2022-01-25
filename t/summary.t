use warnings;
use strict;
use Test::More tests => 12;

use App::SpamcupNG::Summary;
my $instance = new_ok('App::SpamcupNG::Summary');
can_ok( $instance, qw(new as_text tracking_url) );
is( $instance->as_text,
    'tracking_id=not available,mailer=not available,content_type=not available,age=not available,age_unit=not available,receivers=(),contacts=()',
    'as_text returns the expected empty instance'
);

my $tracking_id = 'z6738604873z6ba5c9152db3f6a67929aec945c60dddz';
ok( $instance->set_tracking_id($tracking_id), 'set tracking ID' );
ok( $instance->set_mailer('Foobar Mailer'),   'set mailer' );
ok( $instance->set_content_type('text/plain;charset=utf-8'),
    'set content type' );
ok( $instance->set_age(2),           'set age' );
ok( $instance->set_age_unit('hour'), 'set age unit' );
my $emails_ref = [ 'john@gmail.com', 'doe@gmail.com' ];
my $report_id  = 7164185194;
my @receivers  = map { [ $_, ++$report_id ] } @{$emails_ref};
ok( $instance->set_receivers( \@receivers ), 'set receivers' );
ok( $instance->set_contacts($emails_ref),    'set contacts' );
is( $instance->as_text,
    "tracking_id=$tracking_id"
        . ',mailer=Foobar Mailer,content_type=text/plain;charset=utf-8,age=2,age_unit=hour,receivers=((john@gmail.com,7164185195);(doe@gmail.com,7164185196)),contacts=(john@gmail.com;doe@gmail.com)',
    'as_text returns the expected string'
);
is($instance->tracking_url, "https://www.spamcop.net/sc?id=$tracking_id", 'tracking URL is the expected');
# vim: filetype=perl

