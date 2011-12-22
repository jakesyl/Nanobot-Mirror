#!/usr/local/bin/perl

package nanobot::connection;

use IO::Socket::INET;

sub new {
	my $class = shift;
	my $self = {
		_config		=> shift,
		_output		=> shift
	};

	bless $self;
	return $self;
}

sub start {
	my( $self ) = @_;
	
	$self->{_output}->debug("Attempting connect: " . $self->{_config}->server . ":" . $self->{_config}->port . "\n");

	$self->{_output}->std("Connecting ....................... ");
	$sock = IO::Socket::INET->new(	PeerAddr	=> $self->{_config}->server,
									PeerPort	=> $self->{_config}->port,
									Proto		=> 'tcp',
									Timeout		=> $self->{_config}->connect_timeout
	) or die "\nConnect error: $!\n";
	$self->{_output}->good("[OK]\n");

	if( $self->{_config}->ssl == 1 ) {
		$self->{_output}->std("Starting SSL ..................... ");
			IO::Socket::SSL->start_SSL( $sock,
										SSL_verify_mode => $self->{_config}->sslverify
			) or die "\nSSL handshake failed: $SSL_ERROR";

		$self->{_output}->good("[OK]\n");
	}

	return $sock;
}
1;
