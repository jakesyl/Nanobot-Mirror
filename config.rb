#!/usr/bin/ruby

# Class used for initial bot configuration
# Modify the following variables to your liking
class Config
	def initialize( status, output )
		@nick		= "nanodev"					# Bot nickname
		@user		= "nanobot"					# IRC username
		@pass		= ""						# NickServ password
		@version	= "Nanobot 4.0 beta"		# Version

		@command	= '\?'						# Character prefix for commands (escape special chars)

		@server		= "irc.insomnia247.nl"		# IPv4 address
#		@server		= "127.0.0.1"				# IPv4 address
		@server6	= "irc6.insomnia247.nl"		# IPv6 address
		@port		= 6667						# Normal port
		@sslport	= 6697						# SSL port

		@channels	= ["#bot", "#test"]			# Autojoin channel list

		@opers		= ["insomnia247.nl"]		# Opers list

		@data		= "data"					# Data directory
		@plugins	= "plugins"					# Plugin directory
		@autoload	= []						# Plugin autoload list

		@autorejoin	= 1							# Rejoin on kick
		@rejointime	= 3							# Time to wait before rejoin (seconds)

		@pingwait	= 0							# Wait for server's first PING
		@conn_time	= 20						# Connect timeout
		@timeout	= 300						# IRC timeout

		@use_thread	= 1							# Prefer threading
		@use_ipv6	= 0							# Prefer IPv6
		@use_ssl	= 1							# Prefer SSL
		@verif_ssl	= 0							# Verify SSL certificate
		@rootcert	= "/etc/ssl/certs/ca-certificates.crt"
												# Path to openssl root certs (Needed if verify_ssl is enabled)

		@threadfb	= 1							# Allow fallback to sequential processing when threads aren't available
		@sslfback	= 0							# Allow fallback to insecure connect when SSL isn't available

		@status		= status					# System object, do not modify
		@output		= output					# System object, do not modify
	end

	def nick( nick = "" )
		if( nick != "" )
			@nick = nick
		end
		return @nick
	end

	def user
		return @user
	end

	def pass
		@pass
	end

	def version
		return @version
	end

	def command( command = '' )
		if( command != '' )
			@command = command
		end
		return @command
	end

	def server
		if( @use_ipv6 == 1 )
			return @server6
		else
			return @server
		end
	end

	def port
		if( @use_ssl == 1 && @status.ssl == 1 )
			return @sslport
		elsif( @use_ssl == 1 && @status.ssl == 0 && @sslfback == 1 )
			@output.bad( "Warning: SSL is not available, insecure connection!\n" )
			return @port
		elsif( @use_ssl == 1 && @status.ssl == 0 && @sslfback == 0 )
			@output.info( "SSL is not available, and fallback is disabled.\n" )
			Process.exit
		else
			return @port
		end
	end

	def ssl( ssl = "" )
		if( ssl != "" )
			@use_ssl = ssl
		end
		return @use_ssl
	end

	def verifyssl( ssl = "" )
		if( ssl != "" )
			@verif_ssl = ssl
		end
		return @verif_ssl
	end

	def rootcert
		return @rootcert
	end

	def ipv6( ipv6 = "" )
		if( ipv6 != "" )
			@use_ipv6 = ipv6
		end
		return @use_ipv6
	end

	def threads( threads = "" )
		if( threads != "" )
			@use_thread = threads
		end
		return @use_thread
	end

	def threadingfallback
		return @threadfb
	end

	def connecttimeout
		return @conn_time
	end

	def rejoin( rejoin = "" )
		if( rejoin != "" )
			@autorejoin = rejoin
		end
		return @autorejoin
	end

	def rejointime( rejointime = "" )
		if( rejointime != "" )
			@rejointime = rejointime
		end
		return @rejointime
	end

	def show
		if( @status.showconfig == 1 )
			@output.info( "\nConfiguration:\n" )

			# General bot info
			@output.info( "\tBot info:\n" )
			@output.std( "\tNickname:\t\t" + @nick + "\n" )
			@output.std( "\tUsername:\t\t" + @user + "\n" )
			@output.std( "\tNickServ password:\t" + @pass + "\n" )
			@output.std( "\tVersion:\t\t" + @version + "\n" )
			@output.std( "\tCommand prefix:\t\t" + @command + "\n" )

			# Server info
			@output.info( "\n\tServer info:\n" )
			@output.std( "\tServer (IPv4):\t\t" + @server + "\n" )
			@output.std( "\tServer (IPv6):\t\t" + @server6 + "\n" )
			@output.std( "\tPrefer IPv6:\t\t" + yn(@use_ipv6) + "\n" )
			@output.std( "\tPort:\t\t\t" + @port.to_s + "\n" )
			@output.std( "\tSSL port:\t\t" + @sslport.to_s + "\n" )
			@output.std( "\tSSL Available:\t\t" + yn(@status.ssl) + "\n" )
			@output.std( "\tVerify SSL cert:\t" + yn(@verif_ssl) + "\n" )
			@output.std( "\tPath to root cert:\t" + @rootcert + "\n" )
			@output.std( "\tPrefer SSL:\t\t" + yn(@use_ssl) + "\n" )
			@output.std( "\tFallback if no SSL:\t" + yn(@sslfback) + "\n" )
			@output.std( "\tConnect timeout:\t" + @conn_time.to_s + " seconds\n" )
			@output.std( "\tIRC timeout:\t\t" + @timeout.to_s + " seconds\n" )
			@output.std( "\tWait for first PING:\t" + yn(@pingwait) + "\n" )

			# Channel autojoin
			@output.info( "\n\tAuto join channels:\n" )
			if( @channels[0] == nil )
				@output.std( "\t\t\t\tNone set.\n" )
			end
			@channels.each do |chan|
				@output.std( "\t\t\t\t" + chan + "\n" )
			end

			# Bot admins
			@output.info( "\n\tBot admin hosts:\n" )
			if( @opers[0] == nil )
				@output.std( "\t\t\t\tNone set.\n" )
			end
			@opers.each do |host|
				@output.std( "\t\t\t\t" + host + "\n" )
			end

			# Directory settings
			@output.info( "\n\tDirectories:\n" )
			@output.std( "\tBot data storage:\t" + @data + "\n" )
			@output.std( "\tPlugin directory:\t" + @plugins + "\n" )

			# Autoload plugins
			@output.info( "\n\tAuto load plugins:\n" )
			if( @autoload[0] == nil )
				@output.std( "\t\t\t\tNone set.\n" )
			end
			@autoload.each do |plugin|
				@output.std( "\t\t\t\t" + plugin + "\n" )
			end

			# Kick settings
			@output.info( "\n\tKick settings:\n" )
			@output.std( "\tRejoin after kick:\t" + yn(@autorejoin) + "\n" )
			@output.std( "\tWait before rejoin:\t" + @rejointime.to_s + " seconds\n" )

			# Threading settings
			@output.info( "\n\tThreading settings:\n" )
			@output.std( "\tThreading available:\t" + yn(@status.threads) + "\n" )
			@output.std( "\tUse threading:\t\t" + yn(@use_thread) + "\n" )
			@output.std( "\tAllow thread fallback:\t" + yn(@threadfb) + "\n" )

			# Output settings
			@output.info( "\n\tOutput settings:\n" )
			@output.std( "\tShow output:\t\tYes\n" )
			@output.std( "\tUse colours:\t\t" + yn(@status.colour) + "\n" )
			@output.std( "\tShow debug output:\t" + yn(@status.debug) + "\n" )
			@output.std( "\tDebug level:\t\t" )
			if( @status.debug == 0 )
				@output.std( "None\n" )
			elsif( @status.debug == 1 )
				@output.std( "Normal\n" )
			else
				@output.std( "Extra\n" )
			end

			Process.exit
		end
	end

	def yn( var )
		if( var > 0 )
			return "Yes"
		else
			return "No"
		end
	end	
end
