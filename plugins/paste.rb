#!/usr/bin/env ruby

# Plugin to upload text output that's too long for IRC.
class Paste

	require 'net/http'
	require 'uri'

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status  = status
		@config  = config
		@output  = output
		@irc     = irc
		@timer   = timer

		@url     = "http://www.insomnia247.nl/output_api.php"
	end

	# Default method, called when no argument is given (optional, but highly recomended)
	def main( nick, user, host, from, msg, arguments, con )

		params =  {
			'type' => msg,
			'content' => arguments
		}

		result = Net::HTTP.post_form( URI.parse( @url ), params ).body

		@irc.message( from, "#{nick}: #{msg} result: #{result}" )
	end

	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin uploads text that's too long to output in IRC. Not interactive."
		]

		# Print out help
		help.each do |line|
			if( con )
				@output.c( line + "\n" )
			else
				@irc.notice( nick, line )
			end
		end
	end
end

# The following section of code is the php script that this plugin calls.

#<?php
#        $folder = "output"; // Make sure the php user has write and execute access to this folder.
#        $domain = "https://www.insomnia247.nl/";
#
#        $type = $_POST['type'];
#        $content = $_POST['content'];
#
#        if(empty($type) || empty($content))
#                die("Error: Both 'type' and 'content' need to be set.");
#
#        $filename = $folder. "/" . $type . "-" . time() . ".txt";
#
#        $hFile = fopen($filename, 'w');
#        fwrite($hFile, $content);
#        fclose($hFile);
#
#        $url = $domain . $filename;
#        echo($url);
#?>

# I've used this cron to delete files over 5 days old:
#@daily find /var/www/html/output/* -mtime +5 -exec rm {} \;
