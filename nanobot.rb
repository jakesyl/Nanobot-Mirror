#!/usr/bin/ruby

# Load support files
require 'config.rb'
require 'output.rb'
require 'startup.rb'
require 'status.rb'

# Create support objects
status	= Status.new
config	= Config.new
output	= Output.new( status )
startup	= Startup.new( output, config, status )

# Display banner
output.special( "Starting " + config.version + "\n\n" );

# Check for libraries
startup.checksocket
startup.checkopenssl
startup.checkthreads

# Mark startup object for garbage collection
startup = nil

# Testing stuff, non-permanent code
sock = TCPSocket.open( config.server, config.port )

while line = sock.gets
	puts line.chop
end

sock.close
