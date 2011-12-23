#!/usr/local/bin/perl

package nanobot::parser;

require "commands.pl";

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
	my @forward = @_;

	# See if message is a command
	my $cmd = $self->{_config}->command_char;
	if( $message =~ /^$cmd/ ) {
		parse_command(@forward);
	} else {
		# Message hook
	}
}

sub misc {
	my( $self, $data ) = @_;
}
1;
