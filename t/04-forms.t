## Please see file perltidy.ERR
## Please see file perltidy.ERR
use warnings;
use strict;
use Test::More;
use App::SpamcupNG;
use File::Spec;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($WARN);

use constant BASE_URI =>
  'http://www.spamcop.net/sc?id=z6728954861zb68b40f5446eed4c8aad536ab243baa1z';

note('Parsing an OK HTML document with report submission form');
my $html_doc = read_html('sendreport_form_ok.html');
my $form     = App::SpamcupNG::report_form( $$html_doc, BASE_URI );
isa_ok( $form, 'HTML::Form' );
is(
    $form->attr('name'),
    App::SpamcupNG::TARGET_HTML_FORM,
    'the form returned has the expected name'
);

note('Parsing an HTML document without the expected form');
$html_doc = read_html('missing_sendreport_form.html');
$form = App::SpamcupNG::report_form( $$html_doc, BASE_URI );
is( $form, undef, 'The form is not found' );

done_testing;

sub read_html {
    my $html_file = shift;
    my $full_path = File::Spec->catfile( ( 't', 'responses' ), $html_file );
    open( my $in, '<', $full_path ) or die "Cannot read $full_path: $!";
    local $/ = undef;
    my $content = <$in>;
    close($in);
    return \$content;
}

