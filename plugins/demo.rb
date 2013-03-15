#!/usr/bin/env ruby

# Plugin to demonstrate the working of plugins
class Demo

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
	end

	# Method that will get called just before a plugin is unloaded/reloaded. (optional)
	# If implemented must return true when ready to unload.
	def unload
		@output.std( "Received notification that this plugin will be unloaded.\n" )
		return true
	end

	# Default method, called when no argument is given (optional, but highly recomended)
	def main( nick, user, host, from, msg, arguments, con )
		@irc.message( from, "This is the demo module, function, function_admin and remote are availble." )
	end

	# Method that receives a notification when a user is kicked (optional)
	def kicked( nick, user, host, channel, kicked, reason )
		@irc.message( channel, kicked + " was kicked by " + nick + " for " + reason + "." )
	end

	# Method that receives a notification when a notice is received (optional)
	def noticed( nick,  user,  host,  to,  message )
		@irc.message( nick, "Received notice from: " + nick + ": " + message )
	end

	# Method that receives a notification when a message is received, that is not a command (optional)
	def messaged( nick, user, host, from, message )
		if( @config.nick != nick )
			@irc.message( from, "Received message from: " + nick + ": " + message )
		end
	end

	# Method that receives a notification when a user joins (optional)
	def joined( nick, user, host, channel )
		@irc.message( channel, nick + " joined " + channel + "." )
	end

	# Method that receives a notification when a user parts (optional)
	def parted( nick, user, host, channel )
		@irc.message( channel, nick + " parted " + channel + "." )
	end

	# Method that receives a notification when a user quits (optional)
	def quited( nick, user, host, message )
		@output.std( nick + " quit: " + message )
	end

	# Method that receives numbered server messages like MOTD, rules, names etc. (optional)
	def servermsg( servername, messagenumber, message )
		@output.std( "Specific message #{messagenumber} received from #{servername}: #{message}\n" )
	end

	# Method that receives server messages (optional)
	def miscservermsg( unknown )
		@output.std( "Server message: #{unknown}\n" )
	end
	
	# Method that receives miscellaneous messages that don't fit any other profile (optional)
	def misc( unknown )
		@output.std( "Miscellaneous message: #{unknown}\n" )
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin demonstrates the working of plugins.",
			"  demo function               - Public plugin function.",
			"  demo adminfunction          - Admin only plugin function"
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
		
	# Generic function that can be called by any user
	def function( nick, user, host, from, msg, arguments, con )
		@irc.message( from, nick + " called \"function\" from " + from + "." )
	end

	# Generic function that can only be called by an admin
	def functionadmin( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			# Admin only code goes in here
			@irc.message( from, nick + " called \"function_admin\" from " + from + "." )
		else
			@irc.message( from, "Sorry " + nick + ", this is a function for admins only!" )
		end
	end

	# This function uses a function from another plugin. The help plugin in this example.
	def remote( nick, user, host, from, msg, arguments, con )
		if( @status.checkplugin( "help" ) ) # Returns True if a plugin by that name is loaded.
			plugin = @status.getplugin( "help" ) # We can now use the 'plugin' object to make calls to an external plugin.

			# Send data along to the 'main' function of the 'help' plugin.
			plugin.main( nick, user, host, from, msg, arguments, con )
		else
			# Show error to user
			line = "The plugin this function depends on doesn't appear to be loaded."

			if( con )
				@output.c( line + "\n" )
			else
				@irc.notice( nick, line )
			end
		end
	end

	private
	def something
		# This is an internal function that cannot be called from outside this plugin.
	end
end
