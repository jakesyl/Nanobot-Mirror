#!/usr/bin/env ruby

# Class to do inital checks and load available libraries
class Startup
	def initialize( status, config, output )
		@status	= status
		@config	= config
		@output	= output
	end

	# Check socket library
	def checksocket
		@output.std( "Checking for socket libs ......... " )
		begin
			require 'socket'
			@output.good( "[OK]\n" )
		rescue LoadError
			@output.bad( "[NO]\n" )
			@output.info( "Ruby socket library needs to be installed.\n" )
			Process.exit
		end
	end

	# Check for OpenSSL
	def checkopenssl
		@output.std( "Checking for openssl support ..... " )
		begin
			require 'openssl'

			@output.good( "[OK]" )
			if( @config.ssl )
				@output.good( "\n" )
			else
				@output.info( " (unused)\n" )
			end
			@status.ssl( 1 )
		rescue LoadError
			@output.bad( "[NO]" )
			if( @config.ssl )
				@output.bad( "\n" )
			else
				@output.info( " (unused)\n" )
			end

			@status.ssl( 0 )
		end
	end

	# Check for threading
	def checkthreads
		@output.std( "Checking for threading support ... " )
		begin
			require 'thread'
			@status.threads( 1 )

			@output.good( "[OK]" )
			if( @config.threads )
				@output.good( "\n" )
			else
				@output.info( " (unused)\n" )
			end

		rescue LoadError
			@status.threads( 0 )
	
			@output.bad( "[NO]" )
			if( @config.threads )
				@output.bad( "\n" )
			else
				@output.info( " (unused)\n" )
			end

			if( !@config.threadingfallback )
				@output.info( "No threading support, and fallback is disabled.\n" )
				Process.exit
			end
		end
	end

	def checkreadline
		@output.std( "Checking for readline support .... " )
		begin
			require "readline"
			@status.readline( 1 )

			@output.good( "[OK]\n" )

		rescue LoadError
			@status.readline( 0 )
	
			@output.bad( "[NO]" )
			@output.info( " (using STDIO)\n" )
		end
	end

	def checkoutputqueuing
		if( RUBY_VERSION =~ /^1\.8/ )
			@output.info( "Old Ruby version detected.\n" )
			@output.info( "\tOutput queuing is not available.\n" )
			@output.info( "\tTab completion on console not available.\n" )
			@status.tabcomplete( 0 )
		end
	end

	# Check if directories exist
	def checkdirectorydata
		@output.std( "Checking for data directory ...... " )
		if( File.directory? @config.datadir )
			@output.good( "[OK]\n" )
		else
			begin
				Dir::mkdir( @config.datadir )
				@output.info( "[CREATED]\n" )
			rescue
				@output.bad( "[NO]\n" )
			end
		end
	end

	def checkdirectoryplugins
		@output.std( "Checking for plugin directory .... " )
		if( File.directory? @config.plugindir )
			@output.good( "[OK]\n" )
		else
			begin
				Dir::mkdir( @config.plugindir )
				@output.info( "[CREATED]\n" )
			rescue
				@output.bad( "[NO]\n" )
			end
		end
	end
end
