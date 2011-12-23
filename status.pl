#!/usr/local/bin/perl

package nanobot::status;

sub new {
	my $self = {
		_output		=> 0,
		_colour		=> 1,
		_debug		=> 0,
		_login		=> 0,
		_startup	=> time
	};

	bless $self;
	return $self;
}

sub getoutput {
	my( $self ) = @_;
	return $self->{_output};
}

sub getcolour {
	my( $self ) = @_;
	return $self->{_colour};
}

sub getdebug {
	my( $self ) = @_;
	return $self->{_debug};
}

sub getlogin {
	my( $self ) = @_;
	return $self->{_login};
}

sub getstartup {
	my( $self ) = @_;
	return $self->{_startup};
}

sub setoutput {
	my( $self, $output ) = @_;
	$self->{_output} = $output;
}

sub setcolour {
	my( $self, $colour ) = @_;
	$self->{_colour} = $colour;
}

sub setdebug {
	my( $self, $debug ) = @_;
	$self->{_debug} = $debug;
}

sub setlogin {
	my( $self, $login ) = @_;
	$self->{_login} = $login;
}
1;
