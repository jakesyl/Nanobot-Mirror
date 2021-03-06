#!/usr/bin/env ruby

# Class bot uses to store it's status
# Do not modify variables manually
class Status
	def initialize
		@output			= 1
		@colour			= 1
		@debug			= 0
		@login			= 0
		@threads		= 0
		@readline		= 0
		@tabcomplete	= 1
		@ssl			= 0
		@showconf		= 0
		@console		= 1
		@reconnect		= 1
		@autoload		= 0
		@plugins		= {}
		@startup		= Time.new
		@config			= nil
	end

	# Get/set functions
	def output( output = "" )
		if( output != "" )
			@output = output
		end
		return( @output == 1 )
	end

	def colour( colour = "" )
		if( colour != "" )
			@colour = colour
		end
		return( @colour == 1 )
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
		return( @login == 1 )
	end

	def threads( threads = "" )
		if( threads != "" )
			@threads = threads
		end
		return( @threads == 1 )
	end

	def readline( readline = "" )
		if( readline != "" )
			@readline = readline
		end
		return( @readline == 1 )
	end

	def tabcomplete( tc = "" )
		if( tc != "" )
			@tabcomplete = tc
		end
		return( @tabcomplete == 1 )
	end

	def ssl( ssl = "" )
		if( ssl != "" )
			@ssl = ssl
		end
		return( @ssl == 1 )
	end

	def console( console = "" )
		if( console != "" )
			@console = console
		end
		return( @console == 1 )
	end

	def reconnect( reconnect = "" )
		if( reconnect != "" )
			@reconnect = reconnect
		end
		return( @reconnect == 1 )
	end

	def autoload( autoload = "" )
		if( autoload != "" )
			@autoload = autoload
		end
		return( @autoload == 1 )
	end

	def showconfig( show = "" )
		if( show != "" )
			@showconf = show
		end
		return( @showconf == 1 )
	end

	# Functions to deal with plugins
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

	# Function to calculate uptime string
	def uptime( now = Time.now, start = @startup )
		output = ""
		diff = now - start

		weeks	= ( diff/604800 ).to_i
		days	= ( diff/86400 - ( weeks * 7 ) ).to_i
		hours	= ( diff/3600 - ( days * 24 + weeks * 168 ) ).to_i
		minutes = ( diff/60 - ( hours * 60 + days * 1440 + weeks * 10080 ) ).to_i
		seconds = ( diff - ( minutes * 60 + hours * 3600 + days * 86400 + weeks * 604800 ) ).to_i
		
		if( weeks > 0 )
			output = weeks.to_s + " week"
			if( weeks != 1 )
				output = output + "s"
			end
			output = output + ", "
		end

		if( days > 0 )
			output = output + days.to_s + " day"
			if( days != 1 )
				output = output + "s"
			end
			output = output + ", "
		end

		if( hours > 0 )
			output = output + hours.to_s + " hour"
			if( hours != 1 )
				output = output + "s"
			end
			output = output + ", "
		end

		if( minutes > 0 )
			output = output + minutes.to_s + " minute"
			if( minutes != 1 )
				output = output + "s"
			end
			output = output + " and "
		end

		output = output + seconds.to_s + " second"
		if( seconds != 1 )
			output = output + "s"
		end

		return output
	end

	# Give config object to this object
	def giveConfig( config )
		@config = config
	end

	# Tab complete functions
	def getBaseComplete
		list = [ "quit", "load", "unload", "reload", "loaded", "available" ]
		list = list.inject( @plugins.keys, :<< )
		return list.sort
	end

	def getPluginComplete( plugin )
		if( plugin =~ /^([^\s]+){1,}/ )
			plugin = $1
		end

		if( checkplugin( plugin ) )
			list = @plugins.fetch( plugin ).methods - Object.methods
			return list.sort
		elsif( plugin == "unload" )
			return @plugins.keys.sort
		elsif( plugin == "load" )
			contents = Dir.entries("./" + @config.plugindir + "/" )
			plugs = Array.new
			contents.entries.each do |file|
				if( file =~ /\.rb$/i )
					file.gsub!( /\.rb$/i, "" )
					plugs.push( file )
				end
			end
			return plugs
		elsif( plugin == "reload" )
			return @plugins.keys.sort
		else
			return [ "" ]
		end
	end
end
