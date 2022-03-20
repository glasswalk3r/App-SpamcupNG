package App::SpamcupNG::Summary::Recorder;
use strict;
use warnings;
use Carp qw(confess);
use DBI 1.643;

# VERSION

=pod

=head1 NAME

App::SpamcupNG::Summary::Recorder - class to save Summary to SQLite3

=head1 SYNOPSIS

=head1 DESCRIPTION

This class is used to persist L<App::SpamcupNG::Summary> instances to a SQLite3
database.

=head1 METHODS

=head2 new

=cut

sub new {
    my ( $class, $file ) = @_;
    my $self = { db_file => $file };

    # TODO: add tables names for DRY also replacing in _save_attrib
    $self->{dbh} = DBI->connect( ( 'dbi:SQLite:dbname=' . $file ), '', '' )
        or die $DBI::errstr;
    bless $self, $class;
    return $self;
}

=head2 init

Initialize the database if it doesn't exist yet.

=cut

sub init {
    my $self = shift;
    $self->{dbh}->do(
        q{
CREATE TABLE IF NOT EXISTS email_content_type (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
)
    }
    ) or die $self->{dbh}->errstr;

    $self->{dbh}->do(
        q{
CREATE TABLE IF NOT EXISTS spam_age_unit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
)    
    }
    ) or die $self->{dbh}->errstr;

    $self->{dbh}->do(
        q{
CREATE TABLE IF NOT EXISTS email_charset (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
)
    }
    ) or die $self->{dbh}->errstr;

    $self->{dbh}->do(
        q{
CREATE TABLE IF NOT EXISTS receiver (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL UNIQUE
)
    }
    ) or die $self->{dbh}->errstr;

    $self->{dbh}->do(
        q{
CREATE TABLE IF NOT EXISTS mailer (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
)
    }
    ) or die $self->{dbh}->errstr;

    $self->{dbh}->do(
        q{
CREATE TABLE IF NOT EXISTS summary (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tracking_id TEXT NOT NULL UNIQUE,
  charset_id INTEGER REFERENCES email_charset ON DELETE SET NULL,
  content_type_id INTEGER REFERENCES email_content_type ON DELETE SET NULL,
  age INTEGER NOT NULL,
  age_unit_id INTEGER REFERENCES spam_age_unit ON DELETE SET NULL,
  mailer_id INTEGER REFERENCES mailer ON DELETE SET NULL
)
    }
    ) or die $self->{dbh}->errstr;

    $self->{dbh}->do(
        q{
CREATE TABLE IF NOT EXISTS summary_receiver (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  summary_id INTEGER REFERENCES summary ON DELETE CASCADE,
  receiver_id INTEGER REFERENCES receiver ON DELETE CASCADE,
  report_id TEXT UNIQUE
)
    }
    ) or die $self->{dbh}->errstr;

}

=head2 save

Persists a L<App::Spamcup::Summary> instance to the database.

=cut

sub save {
    my ( $self, $summary ) = @_;
    my $summary_class = 'App::SpamcupNG::Summary';
    my $ref           = ref($summary);
    confess "summary must be instance of $summary_class class, not '$ref'"
        unless ( $ref eq $summary_class );

    # TODO: create a method for Summary to provide those names
    my @fields = qw(content_type age_unit charset mailer);
    my %fields;

    foreach my $field_name (@fields) {
        my $method = "get_$field_name";
        $fields{$field_name}
            = $self->_save_attrib( $field_name, $summary->$method );
    }

    my $summary_id = $self->_save_summary( $summary, \%fields );

    foreach my $receiver ( @{ $summary->get_receivers } ) {
        my $receiver_id = $self->_save_attrib( 'receiver', $receiver->email );
        $self->_save_sum_rec( $summary_id, $receiver_id,
            $receiver->report_id );
    }

}

sub _save_sum_rec {
    my ( $self, $sum_id, $rec_id, $report_id ) = @_;
    my @values = ( $sum_id, $rec_id, $report_id );
    $self->{dbh}->do(
        q{
INSERT INTO summary_receiver (summary_id, receiver_id, report_id)
VALUES(?, ?, ?)
        }, undef, @values
    ) or confess $self->{dbh}->errstr;
}

sub _save_summary {
    my ( $self, $summary, $fields_ref ) = @_;
    my $insert = q{
INSERT INTO summary
(tracking_id, charset_id, content_type_id, age, age_unit_id, mailer_id)
VALUES (?, ?, ?, ?, ?, ?)    
};
    my @values = (
        $summary->get_tracking_id,   $fields_ref->{charset_id},
        $fields_ref->{content_type}, $summary->get_age,
        $fields_ref->{age_unit},     $fields_ref->{mailer}
    );
    $self->{dbh}->do( $insert, undef, @values )
        or confess $self->{dbh}->errstr;
    return $self->{dbh}->last_insert_id;
}

sub _save_attrib {
    my ( $self, $attrib, $value ) = @_;
    my %attrib_to_table = (
        content_type => 'email_content_type',
        age_unit     => 'spam_age_unit',
        charset      => 'email_charset',
        mailer       => 'mailer',
        receiver     => 'receiver'
    );

    return undef unless ( defined($value) );
    confess "'$attrib' is not a valid attribute"
        unless ( exists( $attrib_to_table{$attrib} ) );
    my $table = $attrib_to_table{$attrib};
    my $column;

    if ( $attrib eq 'receiver' ) {
        $column = 'email';
    }
    else {
        $column = 'name';
    }

    my $row_ref
        = $self->{dbh}
        ->selectrow_arrayref( "SELECT id FROM $table WHERE $column = ?",
        undef, $value );
    return $row_ref->[0] if ( defined( $row_ref->[0] ) );

    $self->{dbh}->do(
        qq{
INSERT INTO $table ($column) VALUES (?)
        },
        undef,
        $value
    );

    return $self->{dbh}->last_insert_id;
}

=pod

=head1 SEE ALSO

=over

=item *

L<https://www.sqlite.org/docs.html>

=back

=cut

1;

