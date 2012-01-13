#!/usr/bin/env ruby

# Plugin with some random small tools
class Toolbox
	require 'digest/md5'
	require 'digest/sha1'
	require 'net/http'
	require 'uri'

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
	end

	# Redirect random nothing requests to help
	def main( nick, user, host, from, msg, arguments, con )
		help( nick, user, host, from, msg, arguments, con )
	end

	# MD5 functions
	def md5( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
			line = Digest::MD5.hexdigest( arguments )
			if( con )
				@output.c( line + "\n" )
			else
				@irc.message( from, line )
			end
		end
	end

	def lmd5( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
			line = Net::HTTP.get( 'www.insomnia247.nl', '/hash_api.php?type=md5&hash=' + arguments )

			if( con )
				@output.c( line + "\n" )
			else
				@irc.message( from, line )
			end
		end
	end

	# SHA-1 functions
	def sha1( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
			line = Digest::SHA1.hexdigest( arguments )
			if( con )
				@output.c( line + "\n" )
			else
				@irc.message( from, line )
			end
		end
	end

	def lsha1( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
			line = Net::HTTP.get( 'www.insomnia247.nl', '/hash_api.php?type=sha1&hash=' + arguments )

			if( con )
				@output.c( line + "\n" )
			else
				@irc.message( from, line )
			end
		end
	end

	# Dig command
	def dig( nick, user, host, from, msg, arguments, con )
		valid = true
		reverse = false
		validtype = false

		types = [
			"A", "ANY", "AXFER", "CNAME", "MX", "NS", "PTR", "SOA", "TXT", "A6", "AAAA", "AFSDB", "APL", "ATMA", "CERT", 
			"DNAME", "DNSKEY", "DS", "EID", "GID", "GPOS", "HINFO", "ISDN", "KEY", "KX", "LOC", "MB", "MD", "MF", "MG", "MINFO", 
			"MR", "NAPTR", "NSEC", "NULL", "NSAP", "NSAP-PTR", "NXT", "OPT", "PX", "RP", "RRSIG", "RT", "SIG", "SINK", "SRV", 
			"SSHFP", "TKEY", "TSIG", "UID", "UINFO", "UNSPEC", "WKS", "X25"
		]

		cmd = ""

		if( !arguments.nil? && !arguments.empty? )
			args = arguments.split( ' ', 3 )

			# Determine what we have

			type	= nil
			addr	= nil
			ns		= nil

			args.each do |arg|
				if( arg =~ /^@/ )
					ns = arg.gsub( /^@/, "" )

					# Valid nameserver?
					if( type( ns ) == 0 )
						valid = false
					end

				# Check for reverse lookup
				elsif( arg =~ /^x$/i )
					type = "x"
					validtype = true

				# Check for valid host
				elsif( type( arg ) != 0 )
					addr = arg
				end

				# Check for valid lookup type
				types.each do |t|
					if( arg =~ /^#{t}$/i )
						type = t
						validtype = true
					end
				end
			end
		else
			valid = false
		end

		if( valid && !addr.nil? )
			# Build command string
			cmd = "dig +short "

			if( validtype && type == "x" )
				cmd = cmd + "-x "
			elsif( validtype )
				cmd = cmd + "-t " + type + " "
			else
				cmd = cmd + "-t A "
			end

			cmd = cmd + addr + " "

			if( !ns.nil? )
				cmd = cmd + "@" + ns
			end

			# Execute dig command
			output = `#{cmd}`

			if( con )
				@output.c( output + "\n" )
			else
				@irc.message( from, output )
			end
			
		else
			line = "Not valid input."
			if( con )
				@output.c( line + "\n" )
			else
				@irc.message( from, line )
			end
		end
	end

	# PING command
	def ping( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
		end
	end

	# Webchat IP decoder
	def webchat( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
		end
	end

	# (De-)HEX functions
	def hex( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
		end
	end

	def dehex( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
		end
	end

	# (De-)ASCII functions
	def ascii( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
		end
	end

	def deascii( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
		end
	end

	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin demonstrates the working of plugins.",
			"  toolbox md5 [phrase]          - Calculate md5 hash of given phrase.",
			"  toolbox lmd5 [md5 hash]       - Do a database lookup for given md5 hash.",
			"  toolbox sha1 [phrase]         - Calculate sha1 hash of given phrase.",
			"  toolbox lsha1 [sha1 hash]     - Do a database lookup for given sha1 hash.",
			"  toolbox dig [host]            - Do a (reverse) DNS lookup for a host.",
			"  toolbox ping [host]           - Send a PING request to a host.",
			"  toolbox webchat [hexmask]     - Reverse webchat hex encoded IP address.",
			"  toolbox hex [string]          - Translate string to hex. (According to ASCII table)",
			"  toolbox dehex [hex string]    - Translate string from hex. (According to ASCII table)",
			"  toolbox ascii [string]        - Translate string to ascii values.",
			"  toolbox deascii [string]      - Translate string from ascii values."
		]

		# Print out help
		help.each do |line|
			if( con )
				@output.c( line + "\n" )
			else
				@irc.notice( nick, line )
			end
		end

		if( con )
			@output.c( "Help for demo plugin, help, function and functionadmin are available.\n" )
		else
			@irc.notice( nick, "Help for demo plugin, help, function and functionadmin are available." )
		end
	end

	private

	# Function to parse address type
	def type( host )
		if ( host =~ /^([[:alnum:]]+[.-]{0,1})+\.[[:alpha:]]{1,4}$/ )
			return 1
		elsif ( host =~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/ )
			return 4
		elsif ( host =~ /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/)
			return 6
		else
			return 0
		end
	end
end
