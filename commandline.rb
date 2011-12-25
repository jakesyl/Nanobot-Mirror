#!/usr/bin/ruby

# Class to do parsing of commandline arguments
class CommandlineParser
	def initialize( status, config, output, name )
		@status		= status
		@config		= config
		@output		= output
		@name		= name
	end

	def parse( args )
		args.each do |arg|
			if( arg == "-h" || arg == "--help" )
				printhelp
			elsif( arg == "-s" || arg == "--ssl" )
				@config.ssl( 1 )
			elsif( arg == "-4" || arg == "--ipv4" )
				@config.ipv6( 0 )
			elsif( arg == "-6" || arg == "--ipv6" )
				@config.ipv6( 1 )
			elsif( arg == "-t" || arg == "--thread" || arg == "--threads" || arg == "--threading" )
				@config.threads( 1 )
			elsif( arg == "-nt" || arg == "--no-thread" || arg == "--no-threads" || arg == "--no-threading" )
				@config.threads( 0 )
			elsif( arg == "-q" || arg == "--quiet" )
				@status.output( 0 )
			elsif( arg == "-c" || arg == "--colour" || arg == "--color" )
				@status.colour( 0 )
			elsif( arg == "-d" || arg == "--debug" )
				@status.debug( @status.debug + 1 )
			elsif( arg == "-p" || arg == "--printconfig" )
				@status.showconfig( 1 )
			end
		end
	end

	def printhelp
		@output.info( "Usage:\n" )
		@output.std( "\truby " + @name + " [options]\n\n" )

		@output.info( "Options:\n" )
		@output.std( "\t-h  or --help\t\tPrint this help and quit.\n" )
		@output.std( "\t-s  or --ssl\t\tEnable SSL connections.\n" )
		@output.std( "\t-4  or --ipv4\t\tUse IPv4.\n" )
		@output.std( "\t-6  or --ipv6\t\tUse IPv6.\n" )
		@output.std( "\t-t  or --threads\tEnable threading.\n" )
		@output.std( "\t-nt or --no-threads\tDisable threading.\n" )
		@output.std( "\t-q  or --quiet\t\tDisable normal output.\n" )
		@output.std( "\t-c  or --colour\t\tDisable coloured output.\n" )
		@output.std( "\t-p  or --printconfig\tShow current configuration and quit.\n" )
		@output.std( "\t-d  or --debug\t\tShow debug output. (Use twice for extra effect.)\n" )
		Process.exit
	end

end
