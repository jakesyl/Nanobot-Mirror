#!/usr/local/bin/perl

package nanobot::irc;

sub new {
	my $class = shift;
	my $self = {
		_config		=> shift,
		_output		=> shift,
		_sock		=> shift
	};

	bless $self;
	return $self;
}

sub raw {
	my( $self, $data ) = @_;
	my $sock = $self->{_sock};
	print $sock "$data\n";
	$self->{_output}->extradebug("<== $data\n");
}

sub message {
	my( $self, $to, $message ) = @_;
	raw($self, "PRIVMSG $to :$message");
}

sub notice {
	my( $self, $to, $message ) = @_;
	raw($self, "NOTICE $to :$message");
}

sub nick {
	my( $self, $nick ) = @_;
	$self->{_config}->setnick($nick);
	raw($self, "NICK $nick");
}

sub topic {
	my( $self, $channel, $topic ) = @_;
	raw($self, "TOPIC $channel $topic");
}

sub pong {
	my( $self, $data ) = @_;
	raw($self, "PONG :$data");
}

sub join {
	my( $self, $channel ) = @_;
	raw($self, "JOIN $channel");
}

sub part {
	my( $self, $channel ) = @_;
	raw($self, "PART $channel");
}

sub kick {
	my( $self, $channel, $user, $reason ) = @_;
	raw($self, "KICK $channel $user $reason");
}

sub mode {
	my( $self, $channel, $mode, $user ) = @_;
	raw($self, "MODE $channel $mode $user");
}

sub userinfo {
	my( $self ) = @_;
	raw($self, "NICK " . $self->{_config}->nick );
	raw($self, "USER " . $self->{_config}->user . " 8 *  :" . $self->{_config}->version );
}

sub quit {
	my( $self, $message ) = @_;
	raw($self, "QUIT $message");
}

sub disconnect {
	my( $self ) = @_;
	$sock = $self->{_sock}; 
	close($sock);
}

sub getsock {
	my( $self ) = @_;
	return $self->{_sock};
}
1;
