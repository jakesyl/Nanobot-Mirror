#!/usr/bin/env ruby

# Plugin to keep track of and recover from netsplits
class Netsplit

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status  = status
		@config  = config
		@output  = output
		@irc     = irc
		@timer   = timer

		# Hub address
		@hub     = "hub.tddirc.net"

		# List of nodes we expect to be in the network and have oper permissions on
		@nodes   = [
		             "i247.us.tddirc.net",
		             "i247.uk.tddirc.net",
		             "i247.at.tddirc.net",
		             "i247.nl.tddirc.net"
		           ]

		# Total number of lines expected and received from MAP command
		@lines   = 7
		@receiv  = 0

		# Checking timing
		@wait    = 60
		@timeout = 5

		# Start periodic checking
		if( @status.threads && @config.threads)
			@pcheck	= Thread.new{ checker }
		end
	end

	# Stop checking thread when plugin is unloaded
	def unload
		@pcheck.exit
		return true
	end

	# Display non-interactivity messages
	def main( nick, user, host, from, msg, arguments, con )
		@irc.message( from, "This plugin is not interactive." )
	end

	# Capture MAP response
	def servermsg( servername, messagenumber, message )

		# Check if message is MAP type
		if( messagenumber == "006" )

			#Check if this is the first response
			if( @receiv == 0)
				# Start the timeout
				@timer.action( @timeout, "@status.getplugin(\"netsplit\").timeout( nil, nil, nil, nil, nil, nil, nil )" )
			end

			# Keep track of the total number received
			@receiv += 1
		end
	end

	def test( nick, user, host, from, msg, arguments, con )
		@receiv = 0
		@irc.raw( "MAP" )
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin keeps track and attempts to recover from netsplits."
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

	# Callback function for when we did not receive enough servers
	def timeout( nick, user, host, from, msg, arguments, con )

		# Make sure this function is not being called from IRC
		if( nick != nil )
			@irc.notice( nick, "This function is not meant to be called from IRC.")
		else
			
			# Check if we have as many nodes as we expected
			if( @receiv != @lines )

				# It is probably the node we're on that split off.
				if( @receiv == 1 )
					@output.debug( "Current node seems to have split.\n" )
					@irc.message( "Cool_Fire", "Current node seems to have split." )
				else
					@output.debug( "Some node seems to have split, but not this one.\n" )
					@irc.message( "Cool_Fire", "Some node seems to have split, but not this one." )
				end
			else
				@output.debug( "All nodes seem to be connected.\n" )
			end
			@receiv = 0
		end
	end

	private

	# Periodic checking function
	def checker
		while true
			sleep( @wait )
			@receiv = 0
			@irc.raw( "MAP" )
		end
	end
end
