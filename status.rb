#!/usr/bin/ruby

# Class bot uses to store it's status
# Do not modify variables manually
class Status
	def initialize
		@output		= 1
		@colour		= 1
		@debug		= 0
		@login		= 0
		@threads	= 0
		@ssl		= 0
		@showconf	= 0
		@console	= 1
		@plugins	= {}
		@startup	= Time.new
	end

	def output( output = "" )
		if( output != "" )
			@output = output
		end
		return @output
	end

	def colour( colour = "" )
		if( colour != "" )
			@colour = colour
		end
		return @colour
	end

	def debug( debug = "" )
		if( debug != "" )
			@debug = debug
		end
		return @debug
	end

	def login( login = "" )
		if( login != "" )
			@login = login
		end
		return @login
	end

	def threads( threads = "" )
		if( threads != "" )
			@threads = threads
		end
		return @threads
	end

	def ssl( ssl = "" )
		if( ssl != "" )
			@ssl = ssl
		end
		return @ssl
	end

	def console( console = "" )
		if( console != "" )
			@console = console
		end
		return @console
	end

	def showconfig( show = "" )
		if( show != "" )
			@showconf = show
		end
		return @showconf
	end

	def plugins( plugins = "" )
		if( plugins != "" )
			@plugins = plugins
		end
		return @plugins
	end

	def addplugin( name, plugin )
		@plugins[ name ] = plugin
	end

	def delplugin( name )
		@plugins[ name ] = nil
		@plugins.delete( name )
	end

	def checkplugin( name )
		return( @plugins.has_key?( name ) )
	end

	def getplugin( name )
		return( @plugins.fetch( name ) )
	end

	def startup
		return @startup
	end
end
