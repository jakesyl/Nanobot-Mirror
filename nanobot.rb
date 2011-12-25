#!/usr/bin/ruby

# Load support files
require 'config.rb'
require 'output.rb'
require 'startup.rb'
require 'status.rb'
require 'commandline.rb'
require 'connect.rb'
require 'irc.rb'

# Create support objects
status	= Status.new
output	= Output.new( status )
config	= Config.new( status, output )

# Process commandline options
parser	= CommandlineParser.new( status, config, output, $0 )
parser.parse( ARGV )
parser = nil

# Display banner
output.special( "Starting " + config.version + "\n\n" );

# Check for libraries
startup	= Startup.new( status, config, output )

startup.checksocket
startup.checkopenssl
startup.checkthreads

startup = nil

# Show configuration, if desired.
config.show

# Start connection
socket = Connection.new( status, config, output ).start

# Process IRC input
irc = IRCParser.new( status, config, output, socket ).start
