#!/usr/local/bin/perl

package nanobot::parser;

require "parser_subroutines.pl";

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
	if( $line =~ /^PING \:(.+)/) {
		$output->debug("Received ping\n");
		$irc->pong($1);
	}

	# KICK
	elsif( $line =~ /^\:(.+?)!(.+?)@(.+?) KICK (.+?) (.+?) \:(.+?)/ ) {
		$output->debug("Received kick\n");
		kick( $self, $1, $2, $3, $4, $5, $6 );
	}

	# NOTICE
	elsif( $line =~ /^\:(.+?)!(.+?)@(.+?) NOTICE (.+?) \:(.+)/ ) {
		$output->debug("Received notice\n");
		notice( $self, $1, $2, $3, $4, $5 );
	}

	# JOIN
	elsif( $line =~ /^\:(.+?)!(.+?)@(.+?) JOIN \:(.+)/ ) {
		$output->debug("Received join\n");
		userjoin( $self, $1, $2, $3, $4 );
	}

	# PART
	elsif( $line =~ /^\:(.+?)!(.+?)@(.+?) PART \:(.+)/ ) {
		$output->debug("Received part\n");
		userpart( $self, $1, $2, $3, $4 );
	}

	# QUIT
	elsif( $line =~ /^\:(.+?)!(.+?)@(.+?) QUIT \:(.+)/ ) {
		$output->debug("Received quit\n");
		userquit( $self, $1, $2, $3, $4 );
	}

	# PRIVMSG
	elsif( $line =~ /^\:(.+?)!(.+?)@(.+?) PRIVMSG (.+?) \:(.+)/ ) {
		$output->debug("Received message\n");
		privmsg( $self, $1, $2, $3, $4, $5 );
	}

	# Other stuff
	else {
		misc( $self, $1 );
	}
}
1;
