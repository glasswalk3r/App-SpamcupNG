package App::SpamcupNG::UserAgent;
use warnings;
use strict;
use LWP::UserAgent 6.60;
use HTTP::Cookies 6.10;
use HTTP::Request 6.35;
use Log::Log4perl 1.54 qw(get_logger :levels);

# VERSION

=head1 NAME

App::SpamcupNG::UserAgent - the SpamcupNG HTTP user agent

=head1 SYNOPSIS

=head1 DESCRIPTION

This class is responsible to interact with the Spamcop website, providing
requests and returning the HTML responses.

=head1 METHODS

=head2 new

Creates a new instance.

Expects as parameter:

- version: a string of the version of SpamcupNG.

Returns a new instance.

=cut

sub new {
    my ($class, $version) = @_;
    my $self = {
        name => 'spamcup user agent',
        version => $version,
        members_url => 'http://members.spamcop.net/',
        code_login_url => 'http://www.spamcop.net/?code=',
        report_url => 'http://www.spamcop.net/sc?id=',
        current_base_url => undef
        };

    bless $self, $class;

    my $ua = LWP::UserAgent->new();
    $ua->agent($self->{name} . '/' . $version);
    $ua->cookie_jar( HTTP::Cookies->new() );
    $self->{user_agent} = $ua;
    return $self;
}

=head2 login

Execute the login to Spamcop website.

Expect as parameters:

- id: the ID of a Spamcop account. - password: the password of a Spamcop
account.

Returns the HTML content as a scalar reference.

=cut

sub login {
    my ($self, $id, $password) = @_;
    my $logger = get_logger('SpamcupNG');
    my $request;

    # TODO: check if the cookie is still valid before trying to login again

    if ( $password ) {
        $request = HTTP::Request->new( GET => 'http://members.spamcop.net/' );
        $request->authorization_basic( $id, $password );
    }
    else {
        $request = HTTP::Request->new(
            GET => 'http://www.spamcop.net/?code=' . $id );
    }

    if ( $logger->is_debug() ) {
        $logger->debug( "Request details:\n" . $request->as_string );
    }

    my $response = $self->{user_agent}->request($request);

    if ( $logger->is_debug() ) {
        $logger->debug( "Got HTTP response:\n" . $response->as_string );
    }

    return \($response->content) if ( $response->is_success );

    my $status = $response->status_line();

    if ( $response->code() == 500 ) {
        $logger->fatal("Can\'t connect to server: $status");
    }
    else {
        $logger->warn($status);
        $logger->fatal(
            'Cannot connect to server or invalid credentials. Please verify your username and password and try again.'
            );
    }

    return undef;

}

=head2 spam_report

Fetches a SPAM report.

Expects as parameter a report ID.

Returns the HTML content as a scalar reference.

=cut

sub spam_report {
    my ($self, $report_id) = @_;
    my $logger = get_logger('SpamcupNG');
    my $request = HTTP::Request->new(GET => $self->{report_url} . $report_id );

    if ( $logger->is_debug ) {
        $logger->debug( "Request to be sent:\n" . $request->as_string );
    }

    my $response = $self->{user_agent}->request($request);
    $self->{current_base_url} = $response->base;

    if ( $logger->is_debug ) {
        $logger->debug( "Got HTTP response:\n" . $response->as_string );
    }

    unless ( $response->is_success ) {
        $logger->fatal("Can't connect to server. Try again later.");
        return undef;
    }

    return \($response->content);
}

=head2 base

Returns the current base URL provided by the last response of getting a SPAM
report.

=cut

sub base {
    my $self = shift;
    return $self->{current_base_url};
}

=head2 complete_report

Complete the SPAM report, by confirming it's information is OK.

Returns the HTML content as a scalar reference.

=cut

sub complete_report {
    my ($self, $http_request) = @_;
    my $logger = get_logger('SpamcupNG');
    my $response = $self->{user_agent}->request($http_request);

    if ( $logger->is_debug ) {
        $logger->debug( "Got HTTP response:\n" . $response->as_string );
    }

    unless ( $response->is_success ) {
        $logger->fatal(
            'Cannot connect to server. Try again later. Quitting.');
        return undef;
    }

    return \($response->content);
}

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
