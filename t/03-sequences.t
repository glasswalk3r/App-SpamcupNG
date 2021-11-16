use warnings;
use strict;
use Test::More;
use App::SpamcupNG;
use Log::Log4perl qw(:easy);

use lib './t';
use Fixture 'read_html';

Log::Log4perl->easy_init($WARN);

is(
    App::SpamcupNG::_check_next_id( read_html('after_login.html') ),
    'z6444645586z5cebd61f7e0464abe28f045afff01b9dz',
    'got the expected next SPAM id'
);

is(
    App::SpamcupNG::_check_error( read_html('failed_load_header.html') ),
    'Failed to load spam header: 64446486 / cebd6f7e464abe28f4afffb9d',
    'get the expected error'
);

is(
    App::SpamcupNG::_check_error( read_html('mailhost_problem.html') ),
    'Mailhost configuration problem, identified internal IP as source',
    'get the expected error'
);

done_testing;
