#!/usr/local/bin/perl

package nanobot::output;

my $RED		= "\033[31m";
my $GREEN	= "\033[32m";
my $YELLOW	= "\033[33m";
my $BLUE	= "\033[34m";
my $END		= "\033[0m";

sub new {
	my $class = shift;
	my $self = {
		_status		=> shift
	};

	bless $self;
	return $self;
}

sub std {
	my( $self, $message ) = @_;

	if( $self->{_status}->getoutput == 1) {
		print STDOUT "${message}";
	}
}

sub info {
	my( $self, $message ) = @_;

	if( $self->{_status}->getoutput == 1) {
		if( $self->{_status}->getcolour == 1) {
			print STDOUT "$YELLOW$message$END";
		} else {
			print STDOUT "${message}";
		}
	}
}

sub good {
	my( $self, $message ) = @_;

	if( $self->{_status}->getoutput == 1) {
		if( $self->{_status}->getcolour == 1) {
			print STDOUT "$GREEN$message$END";
		} else {
			print STDOUT "${message}";
		}
	}
}

sub bad {
	my( $self, $message ) = @_;

	if( $self->{_status}->getoutput == 1) {
		if( $self->{_status}->getcolour == 1) {
			print STDOUT "$RED$message$END";
		} else {
			print STDOUT "${message}";
		}
	}
}

sub special {
	my( $self, $message ) = @_;

	if( $self->{_status}->getoutput == 1) {
		if( $self->{_status}->getcolour == 1) {
			print STDOUT "$BLUE$message$END";
		} else {
			print STDOUT "${message}";
		}
	}
}

sub debug {
	my( $self, $message ) = @_;

	if( $self->{_status}->getdebug >= 1) {
		print STDOUT "${message}";
	}
}

sub extradebug {
	my( $self, $message ) = @_;

	if( $self->{_status}->getdebug == 2) {
		print STDOUT "${message}";
	}
}
1;
