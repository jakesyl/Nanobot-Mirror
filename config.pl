#!/usr/local/bin/perl

package nanobot::config;

sub new {
	my $class = shift;
	my $self = {
		_nick		=> "nanodev",				# Bot nickname
		_user		=> "nanobot",				# IRC username
		_pass		=> "",						# NickServ password
		_version	=> "Nanobot 4.0 beta",		# Version

		_attention	=> "!",						# Character prefix for commands

		_server		=> "irc.insomnia247.nl",	# IPv4 address
		#_server		=> "127.0.0.1",				# IPv4 address
		_server6	=> "irc6.insomnia247.nl",	# IPv6 address
		_port		=> 6667,					# Normal port
		_sslport	=> 6697,					# SSL port

		_channels	=> ("#bot", "#test"),		# Autojoin channel list

		_opers		=> ("insomnia247.nl"),		# Opers list

		_data		=> "data",					# Data directory
		_plugins	=> "plugins",				# Plugin directory
		_autoload	=> (),						# Plugin autoload list

		_pingwait	=> 0,						# Wait for server's first PING
		_conn_time	=> 20,						# Connect timeout
		_timeout	=> 300,						# IRC timeout

		_use_ipv6	=> 0,						# Prefer IPv6
		_use_ssl	=> 0,						# Prefer SSL
		_ssl_verif	=> 0x00,					# Verification process to be performed on peer certificate.
												# This can be a combination of
												#	0x00 (don't verify)
												#	0x01 (verify peer)
												#	0x02 (fail verification if there's no peer certificate)
												#	0x04 (verify client once)

		_sslfback	=> 0,						# Allow fallback to insecure connect when SSL isn't available
		_ipv6fback	=> 1,						# Allow fallback to IPv4 when IPv6 isn't available

		_output		=> shift					# System object, do not modify
	};

	bless $self;
	return $self;
}

sub nick {
	my( $self ) = @_;
	return $self->{_nick};
}

sub setnick {
	my( $self, $nick ) = @_;
	$self->{_nick} = $nick;
}

sub user {
	my( $self ) = @_;
	return $self->{_user};
}

sub pass {
	my( $self ) = @_;
	return $self->{_pass};
}

sub version {
	my( $self ) = @_;
	return $self->{_version};
}

sub server {
	my( $self, $ipv6 ) = @_;

	if( $self->{_use_ipv6} == 0 ) {			# IPv4
		return $self->{_server};
	} elsif( $ssl == 1 ) {					# IPv6
		return $self->{_server6};
	} elsif( $self->{_ipv6fback} == 1 ) {	# IPv6 not available, do fallback
		$self->{_output}->info("IPv6 is not available, doing fallback to IPv4.\n");
		$self->{_use_ipv6} = 0;
		return $self->{_server};
	} else {								# No IPv6, and no fallback
		die("IPv6 not available, and fallback not allowed.\n");
	}
}

sub port {
	my( $self, $ssl ) = @_;

	if( $self->{_use_ssl} == 0 ) {			# No SSL
		return $self->{_port};
	} elsif( $ssl == 1 ) {					# Use SSL
		return $self->{_sslport};
	} elsif( $self->{_sslfback} == 1 ) {	# SSL not available, do fallback
		$self->{_output}->bad("SSL is not available, doing fallback!\n");
		$self->{_use_ssl} = 0;
		return $self->{_port};
	} else {								# No SSL, and no fallback
		die("SSL not available, and fallback not allowed.\n");
	}
}

sub connect_timeout {
	my( $self ) = @_;
	return $self->{_conn_time};
}

sub ping_timeout {
	my( $self ) = @_;
	return $self->{_timeout};
}

sub ssl {
	my( $self ) = @_;
	return $self->{_use_ssl};
}

sub sslverify {
	my( $self ) = @_;
	return $self->{_ssl_verif};
}

sub ipv6 {
	my( $self ) = @_;
	return $self->{_use_ipv6};
}
1;
