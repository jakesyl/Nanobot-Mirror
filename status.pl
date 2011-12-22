#!/usr/local/bin/perl

package nanobot::status;

sub new {
	my $self = {
		_output		=> 1,
		_colour		=> 1,
		_debug		=> 0
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
1;
