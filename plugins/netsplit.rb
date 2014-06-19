#!/usr/bin/env ruby
# Plugin to keep track of and recover from netsplits

require 'rubygems'
require 'json'

class Netsplit

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status  = status
		@config  = config
		@output  = output
		@irc     = irc
		@timer   = timer

		# User to notify
		@cnffile = "#{@config.datadir}/netsplit.json"
		@script  = "#{@config.datadir}/recoverybot.rb"
		@nuser   = ""
		@rubyloc = ""


		# Hub address
		@hub     = ""

		# List of nodes we expect to be in the network and have oper permissions on
		@nodes   = Array.new
		@found   = ""

		# Total number of lines expected and received from MAP command
		@lines   = 0
		@receiv  = 0

		# Checking timing
		@wait    = 0
		@timeout = 0

		# Store some state
		@state   = ""

		# Load configuration
		load_config

		# Start periodic checking
		if( @status.threads && @config.threads)
			@pcheck	= Thread.new{ checker }
			@mutex  = Mutex.new
		end
	end

	# Stop checking thread when plugin is unloaded
	def unload
		if( @status.threads && @config.threads)
			@pcheck.exit
		end
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
			@mutex.synchronize {
				if( @receiv == 0 )
					# Start the timeout
					@timer.action( @timeout, "@status.getplugin(\"netsplit\").timeout( nil, nil, nil, nil, nil, nil, nil )" )
				end


				# Keep track of the total number received
				@receiv += 1
				@found = "#{@found} #{message}"
			}
		end
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
			@irc.notice( nick, "This function is not meant to be called directly.")
		else
			
			# Check if we have as many nodes as we expected
			@mutex.synchronize {
				localstate = ""
				missing = ""
				if( @receiv != @lines )

					if( @receiv == 1 )
						puts "receiv == 1"
						# It is probably the node we're on that split off

						@nodes.each do |node|
							if( @found.include? node )
								localstate = "#{node} has split."
								missing = node
							end
						end
					else
						# Some other node split off
						puts "receiv == many"
						@nodes.each do |node|
							if( !@found.include? node )
								localstate = "#{node} has split."
								missing = node
							end
						end
					end
				else
					localstate = "All nodes seem to be connected."
				end

				# Tell admin about changes in state
				@output.debug( "#{localstate}\n" )
				if( localstate != @state )
					@irc.message( @nuser, localstate )
					@state = localstate
				end

				# Attempt recovery of missing node
				if( missing != "" )
					recover( missing )
				end

				@receiv = 0
				@found  = ""
			}
		end
	end

	private

	# Load config from file
	def load_config
		if File.exists?( @cnffile )

			jsonline = ""
			File.open( @cnffile ) do |file|
				file.each do |line|
					jsonline << line
				end
			end
			parsed = JSON.parse( jsonline )

			@hub     = parsed[ 'hub_address' ]
			@lines   = parsed[ 'total_nodes' ]
			@nuser   = parsed[ 'notify_user' ]
			@rubyloc = parsed[ 'ruby_location' ]
			@wait    = parsed[ 'check_freqency' ]
			@timeout = parsed[ 'map_reply_timeout' ]

			parsed[ 'nodes' ].each do |node|
				@nodes.push( node[ 'name' ] )
			end
		end
	end

	# Periodic checking function
	def checker
		while true
			sleep( @wait )
			@receiv = 0
			@irc.raw( "MAP" )
		end
	end

	# Fire off recovery attempt
	def recover( node )
		# Build command
		cmd = "#{@rubyloc} #{@script} #{node}"

		# Run shell command to attempt recovery
		result = `#{cmd}`

		# Check if successful
		@output.debug( result )
		
	end
end
