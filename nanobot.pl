#!/usr/local/bin/perl

package nanobot;

# Load support files
require "status.pl";
require "output.pl";
require "config.pl";
require "startup.pl";
require "irc.pl";
require "timer.pl";

# Create support objects
$status	= new nanobot::status;
$output	= new nanobot::output($status);
$config	= new nanobot::config($output);

# Display banner
$output->special("Starting " . $config->version . "\n\n");

# Do startup checks
&detect_threads;
&detect_timer;
&detect_module_load;
&detect_ipv6;
&detect_ssl;

# Start connection
$sock	= new nanobot::connection($config, $output)->start; 

# Create IRC object
$irc	= new nanobot::irc($config, $output, $sock);

# Create timer object
$timer	= new nanobot::timer($config, $output, $irc);

$irc->userinfo;
$irc->msg("#channel", "bot har har");

$timer->action(4, "TIMER event");

sleep(10);
