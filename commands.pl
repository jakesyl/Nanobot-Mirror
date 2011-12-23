#/usr/local/bin/perl

package nanobot::parser;

sub parse_command {
	my( $self, $nick, $user, $host, $from, $command ) = @_;
	my @forward = @_;

	# Strip command character
	$command =~ s/^.//;

	# Public commands
	if   ( $command =~ /^version/)		{ &version(@forward); }
	elsif( $command =~ /^uptime/)		{ &uptime(@forward); }
	elsif( $command =~ /^help/)			{}
	elsif( $command =~ /^available/)	{}
	elsif( $command =~ /^loaded/)		{}

	# Admin commands
	elsif( $command =~ /^load/)			{}
	elsif( $command =~ /^unload/)		{}
	elsif( $command =~ /^reload/)		{}
	elsif( $command =~ /^raw/)			{}
	elsif( $command =~ /^msg/)			{}
	elsif( $command =~ /^join/)			{}
	elsif( $command =~ /^part/)			{}
	elsif( $command =~ /^nick/)			{}
	elsif( $command =~ /^quit/)			{ &quit(@forward); }
	elsif( $command =~ /^op/)			{}
	elsif( $command =~ /^deop/)			{}
	elsif( $command =~ /^hop/)			{}
	elsif( $command =~ /^dehop/)		{}
	elsif( $command =~ /^voice/)		{}
	elsif( $command =~ /^devoice/)		{}
	elsif( $command =~ /^kick/)			{}
	elsif( $command =~ /^ban/)			{}
	elsif( $command =~ /^bantime/)		{}
	elsif( $command =~ /^unban/)		{}
	elsif( $command =~ /^kickban/)		{}
	elsif( $command =~ /^kickbantime/)	{}
	elsif( $command =~ /^mode/)			{}
	elsif( $command =~ /^bot/)			{}
	elsif( $command =~ /^prefix/)		{}
	elsif( $command =~ /^admin/)		{}
	elsif( $command =~ /^\w/)			{}
}

sub version {
	my( $self, $nick, $user, $host, $from, $command ) = @_;
	$self->{_irc}->notice($nick, "Version: " . $self->{_config}->version);
	$self->{_output}->info($nick . " requested version.\n");
}

sub uptime {
	my( $self, $nick, $user, $host, $from, $command ) = @_;
	$uptime = time - $self->{_status}->getstartup;

	$self->{_irc}->notice($nick, "Uptime: " . &diff_string($uptime) );
	$self->{_output}->info($nick . " requested uptime.\n");
}

sub quit {
	my( $self, $nick, $user, $host, $from, $command ) = @_;
	my( $cmd, @msg ) = split(/ /, $command);

	if( $msg[0] eq "" ) {
		$self->{_irc}->quit($self->{_config}->nick . " was instructed to quit.");
	} else {
		$self->{_irc}->quit(join(' ', @msg));
	}

	$self->{_output}->info($nick . " issued quit command.\n");
}

sub diff_string {
	my ($s,$m,$h,$d,$mo) = gmtime( $_[0] );
	my $return = "";

	if( $mo > 0 ) {
		$return = "$mo month";
		if( $mo != 1 ) { $return = $return . "s"; }
		$return = $return . ", ";
	}

	$d--;
	if( $d > 0 ) {
		$return = $return . "$d day";
		if( $d != 1 ) { $return = $return . "s"; }
		$return = $return . ", ";
	}

	if( $h > 0 ) {
		$return = $return . "$h hour";
		if( $h != 1 ) { $return = $return . "s"; }
		$return = $return . ", ";
	}

	if( $m > 0 ) {
		$return = $return . "$m minute";
		if( $m != 1 ) { $return = $return . "s"; }
		$return = $return . ", ";
	}

	$return = $return . "$s second";
	if( $s != 1 ) { $return = $return . "s"; }
	$return = $return . ".";
}
1;
