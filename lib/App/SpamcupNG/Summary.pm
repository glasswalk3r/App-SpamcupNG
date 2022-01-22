package App::SpamcupNG::Summary;
use warnings;
use strict;
use parent qw(Class::Accessor);

# VERSION

=pod

=head1 NAME

App::SpamcupNG::Summary - class to summarise SPAM report data

=head1 SYNOPSIS

    use App::SpamcupNG::Summary;
    my $summary = App::SpamcupNG::Summary->new;
    $summary->set_age(16);

=head1 DESCRIPTION

This class is used internally to store SPAM report data that can latter be
saved to generate reports.

This class is also based on L<Class::Accessor> and uses
C<follow_best_practice>.

=head1 ATTRIBUTES

=over

=item id: the SPAM report unique ID.

=item mailer: the e-mail header C<X-Mailer>, if available. Might be C<undef>.

=item content_type: the e-mail header C<Content-Type>, if available. Might be C<undef>.

=item age: the time elapsed since the SPAM e-mail was received.

=item age_unit: the time elapsed unit since the SPAM e-mail was received.

=item contacts: an array reference with the "best contacts" found in the report.

=item receivers: an array reference with the e-mail addresses.

=back

Sometimes the C<receivers> addresses will not real ones, but "counters" that
will not be used for the report, but only for Spamcop statistics.

=cut

__PACKAGE__->follow_best_practice;
my @fields = (
    'id',       'mailer',   'content_type', 'age',
    'age_unit', 'contacts', 'receivers'
    );
__PACKAGE__->mk_accessors(@fields);

=head1 METHODS

=head2 new

Creates a new instance. No parameter is required or expected.

=cut

sub new {
    my ( $class, $attribs_ref ) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

=head2 as_text

Returns the summary attributes as strings, separated by commas.

If some of attributes are C<undef>, the string C<not avaialable> will be used
instead.

=cut

sub as_text {
    my $self    = shift;
    my @scalars = qw(id mailer content_type age age_unit);
    my @dump = map { $_ . '=' . ( $self->{$_} || 'not available' ) } @scalars;

    foreach my $key (qw(receivers contacts)) {
        if ( $self->{$key} ) {
            push( @dump,
                ( "$key=(" . join( ';', @{ $self->{$key} } ) . ')' ) );
        }
        else {
            push( @dump, "$key=()" );
        }
    }

    return join( ',', @dump );
}

=head1 SEE ALSO

=over

=item *

L<Class::Accessor>

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018 of Alceu Rodrigues de Freitas Junior,
E<lt>arfreitas@cpan.orgE<gt>

This file is part of App-SpamcupNG distribution.

App-SpamcupNG is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

App-SpamcupNG is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
App-SpamcupNG. If not, see <http://www.gnu.org/licenses/>.

=cut

1;