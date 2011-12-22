#!/usr/local/bin/perl

package nanobot::parser;

sub new {
	my $class = shift;
	my $self = {
		_config		=> shift,
		_output		=> shift,
		_status		=> shift,
		_irc		=> shift,
		_timer		=> shift
	};

	bless $self;
	return $self;
}

sub startup {
	my( $self ) = @_;
	my $sock = $self->{_irc}->getsock;

	local $SIG{ALRM} = sub {$sock->shutdown(0);};

	while( <$sock> ) {
		eval {
			alarm 0;
			threads->create(\&parser, $self, $_ )->detach;
			alarm $self->{_config}->ping_timeout;
		};
	}

	close( $sock );
	$self->{_status}->setlogin(0);
}

sub parser {
	my( $self, $line ) = @_;

	chop( $line );
	chop( $line );

	my $config = $self->{_config};
	my $output = $self->{_output};
	my $status = $self->{_status};
	my $irc = $self->{_irc};

	$output->extradebug("==> " . $line . "\n");

	# (Raw data hook)
	# PING
	# KICK
	# NOTICE
	# JOIN
	# PART
	# PRIVMSG
}
1;
