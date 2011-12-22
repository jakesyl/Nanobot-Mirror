#!/usr/local/bin/perl

package nanobot::timer;

sub new {
	my $class = shift;
	my $self = {
		_config		=> shift,
		_output		=> shift,
		_irc		=> shift
	};

	bless $self;
	return $self;
}

sub action {
	my( $self, $timeout, $action ) = @_;
	threads->create(\&subthread, $self, $timeout, $action)->detach;
}

sub subthread {
	my( $self, $timeout, $action ) = @_;
	sleep($timeout);
	$self->{_irc}->raw($action);
}
1;
