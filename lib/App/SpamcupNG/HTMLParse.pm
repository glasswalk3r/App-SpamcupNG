package App::SpamcupNG::HTMLParse;
use strict;
use warnings;
use HTML::TreeBuilder::XPath 0.14;
use Exporter 'import';

our @EXPORT_OK = qw(find_next_id find_errors);

my %regexes = (
    no_user_id => qr/\>No userid found\</i,
    next_id    => qr/sc\?id\=(.*?)\"\>/i,
    http_500   => qr/500/,
);

# TODO: use XPath instead of regex
sub find_next_id {
    my $content_ref = shift;
    my $next_id;

    if ( $$content_ref =~ $regexes{next_id} ) {
        $next_id = $1;
    }

    return $next_id;
}

# TODO: create a single tree instance and check for everything at once
sub find_warnings {
    my $content_ref = shift;
    my $tree        = HTML::TreeBuilder::XPath->new;
    $tree->parse_content($$content_ref);
    my @errors = $tree->findnodes('//div[@id="content"]/div[@class="warn"]');

    if ( scalar(@errors) > 0 ) {
        return $errors[0]->as_trimmed_text;
    }
    else {
        return;
    }
}

sub find_errors {
    my $content_ref = shift;
    my $tree        = HTML::TreeBuilder::XPath->new;
    $tree->parse_content($$content_ref);
    my @errors = $tree->findnodes('//div[@id="content"]/div[@class="error"]');

    if ( scalar(@errors) > 0 ) {
        return $errors[0]->as_trimmed_text;
    }
    else {
        return;
    }
}

sub find_best_contacts {
    my $content_ref = shift;
    my $tree        = HTML::TreeBuilder::XPath->new;
    $tree->parse_content($content_ref);
    my @nodes = $tree->findnodes('//div[@id="content"]');

    foreach my $node (@nodes) {
        for my $html_element ( $node->content_list ) {

            # only text
            next if ref($html_element);
            $html_element =~ s/^\s+//;
            if ( index( $html_element, 'Using best contacts' ) == 0 ) {
                my @tokens = split( /\s/, $html_element );
                splice( @tokens, 0, 3 );
                return \@tokens;
            }
        }

    }

    return [];
}

sub find_spam_header {
    my $raw_spam_header = shift;
    my $formatted //= 0;
    my $tree = HTML::TreeBuilder::XPath->new;
    $tree->parse_content($raw_spam_header);
    my @nodes = $tree->findnodes_as_strings('//text()');
    my @lines;

    for ( my $i = 0 ; $i <= scalar(@nodes) ; $i++ ) {
        next unless $nodes[$i];
        $nodes[$i] =~ s/^\s++//u;

        if ($formatted) {
            push( @lines, "\t$nodes[$i]" );

        }
        else {
            push( @lines, $nodes[$i] );

        }
    }
    return \@lines;
}

1;
