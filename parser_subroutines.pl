#!/usr/local/bin/perl

package nanobot::parser;

sub kick {
	my( $self, $nick, $user, $host, $channel, $kicked, $reason ) = @_;

	# Rejoin on kick
	if( ($kicked =~ $self->{_config}->nick) && ($self->{_config}->auto_rejoin == 1) ) {
		$self->{_timer}->action($self->{_config}->rejoin_time, "JOIN $channel");
	}
}

sub notice {
	my( $self, $nick, $user, $host, $to, $message ) = @_;
}

sub userjoin {
	my( $self, $nick, $user, $host, $channel ) = @_;
}

sub userpart {
	my( $self, $nick, $user, $host, $channel ) = @_;
}

sub userquit {
	my( $self, $nick, $user, $host, $message ) = @_;
}

sub privmsg {
	my( $self, $nick, $user, $host, $from, $message ) = @_;
}

sub misc {
	my( $self, $data ) = @_;
}
1;
