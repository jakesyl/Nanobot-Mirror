#!/usr/local/bin/perl

package nanobot;

# Look for threading support
sub detect_threads {
	$output->std("Checking for threading support ... ");
	eval {
		require threads;
		require threads::shared;
	};

	unless($@) {
		$ssl = 1;
		$output->good("[OK]\n");
	} else {
		$output->bad("[NO]\n");
		$output->bad("threads and threads::shared ara core requirements, please perl threads!\n");
		die;
	}
}

# Look for timer support
sub detect_timer {
	$output->std("Checking for timer support ....... ");
	eval {
		require Time::HiRes;
	};

	unless($@) {
		$ssl = 1;
		$output->good("[OK]\n");
	} else {
		$output->bad("[NO]\n");
		$output->bad("Time::HiRes is a core requirement, please install it!\n");
		die;
	}
}

# Look for module support
sub detect_module_load {
	$output->std("Checking for module support ...... ");
	eval {
		require Module::Load;
	};

	unless($@) {
		$ssl = 1;
		$output->good("[OK]\n");
	} else {
		$output->bad("[NO]\n");
		$output->bad("Module::Load is a core requirement, please install it!\n");
		die;
	}
}

# Look for IPv6 support
sub detect_ipv6 {
	$output->std("Checking for IPv6 support ........ ");
	$ipv6 = 0;
	eval {
		require IO::Socket::INET6;
	};

	unless($@) {
		$ipv6 = 1;
		$output->good("[OK]\n");
		require "connect6.pl"
	} else {
		$output->bad("[NO]\n");
		require "connect.pl"
	}
}

# Look for SSL support
sub detect_ssl {
	$output->std("Checking for SSL support ......... ");
	$ssl = 0;
	eval {
		require IO::Socket::SSL;
	};

	unless($@) {
		$ssl = 1;
		$output->good("[OK]\n");
	} else {
		$output->bad("[NO]\n");
	}
}
1;
