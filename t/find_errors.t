use warnings;
use strict;
use Test::More tests => 24;
use Test::Exception;
use App::SpamcupNG::HTMLParse qw(find_errors);

use lib './t';
use Fixture 'read_html';

note('Failure to load SPAM header');
my $errors_ref = find_errors( read_html('failed_load_header.html') );
is( ref($errors_ref), 'ARRAY',
    'result from find_errors is an array reference' );
is(
    $errors_ref->[0]->message(),
    'Failed to load spam header: 64446486 / cebd6f7e464abe28f4afffb9d',
    'get the expected "load SPAM header" error'
);
isnt( $errors_ref->[0]->is_fatal(), 1, 'Error is not fatal' );

note('Mailhost problem');
$errors_ref = find_errors( read_html('mailhost_problem.html') );
is( ref($errors_ref), 'ARRAY',
    'result from find_errors is an array reference' );
cmp_ok( scalar( @{$errors_ref} ),
    '==', 3, 'Got the expected number of errors' );
my @expected = (
    'Mailhost configuration problem, identified internal IP as source.',
    'Mailhost:',
'please correct this situation - register every email address where you receive spam.'
);
is(
    $errors_ref->[0]->message(),
    join( ' ', @expected ),
    'Got the first expected error'
);
isnt( $errors_ref->[0]->is_fatal(), 1, 'Error is not fatal' );
is(
    $errors_ref->[1]->message(),
    'No source IP address found, cannot proceed.',
    'Got the second expected error'
);
isnt( $errors_ref->[1]->is_fatal(), 1, 'Error is not fatal' );
is(
    $errors_ref->[2]->message(),
    'Nothing to do.',
    'Got the third expected error'
);
is( $errors_ref->[2]->is_fatal(), 1, 'Error is fatal' );

note('Bounce error');
$errors_ref = find_errors( read_html('bounce_error.html') );
is( ref($errors_ref), 'ARRAY',
    'result from find_errors is an array reference' );
cmp_ok( scalar( @{$errors_ref} ),
    '==', 1, 'Got the expected number of errors' );
@expected = (
    'Your email address, glasswalk3r@yahoo.com.br has returned a bounce,',
    'Subject: Delivery Status Notification (Failure),',
'Reason: 5.4.7 - Delivery expired (message too old) \'DNS Soft Error looking up yahoo=.',
'Please, access manually the Spamcop website and fix this before trying to run spamcup again.'
);
is(
    $errors_ref->[0]->message(),
    join( ' ', @expected ),
    'Got the expected error message'
);
is( $errors_ref->[0]->is_fatal(), 1, 'Error is fatal' );
throws_ok { find_errors('foobar') } qr/scalar\sreference/,
  'find_errors dies with invalid parameter';

note('Login error');
$errors_ref = find_errors( read_html('login_failed.html') );
is( ref($errors_ref), 'ARRAY',
    'result from find_errors is an array reference' );
cmp_ok( scalar( @{$errors_ref} ),
    '==', 1, 'Got the expected number of errors' );
is( $errors_ref->[0]->is_fatal(), 1, 'Error is fatal' );
is(
    $errors_ref->[0]->message(),
'Login failed, please try again (is your caps-lock on?). Also consider obtaining a password to Spamcop.net instead of using the old-style authorization token.',
    'Got the expected error message'
);

note('Reports disabled');
$errors_ref = find_errors( read_html('reports_disabled.html') );
is( ref($errors_ref), 'ARRAY',
    'result from find_errors is an array reference' );
cmp_ok( scalar( @{$errors_ref} ),
    '==', 1, 'Got the expected number of errors' );
is( $errors_ref->[0]->is_fatal(), 0, 'Error is not fatal' );
is(
    $errors_ref->[0]->message(),
    'Reports disabled for bondedsender@admin.spamcop.net',
    'Got the expected error message'
);

done_testing;
