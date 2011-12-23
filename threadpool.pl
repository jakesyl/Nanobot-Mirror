#!/usr/local/bin/perl

package nanobot::threadpool;

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
}
1;
