#!/usr/bin/ruby

# Class to do inital checks and load available libraries
class Startup
	def initialize( status, config, output )
		@status	= status
		@config	= config
		@output	= output
	end

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

	def checkopenssl
		@output.std( "Checking for openssl support ..... " )
		begin
			require 'openssl'
			@output.good( "[OK]\n" )
			@status.ssl( 1 )
		rescue LoadError
			@output.bad( "[NO]\n" )
			@status.ssl( 0 )
		end
	end

	def checkthreads
		@output.std( "Checking for threading support ... " )
		begin
			require 'thread'
			@status.threads( 1 )
			@output.good( "[OK]\n" )
		rescue LoadError
			@status.threads( 0 )
			@output.bad( "[NO]\n" )

			if( !@config.threadingfallback )
				@output.info( "No threading support, and fallback is disabled.\n" )
				Process.exit
			end
		end
	end
end
