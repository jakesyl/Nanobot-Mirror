#!/usr/bin/env ruby

# Plugin to do some math
class Calc

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status  = status
		@config  = config
		@output  = output
		@irc     = irc
		@timer   = timer
	end

	# Default method, called when no argument is given (optional, but highly recomended)
	def main( nick, user, host, from, msg, arguments, con )

		# Check for invalid input
		if( arguments =~ /^([0-9]|\.|,|\+|-|\*|\/|%|\(|\)|e|pi|acos|acosh|asin|asinh|atan|atanh|cbrt|cos|cosh|erf|erfc|exp|frexp|gamma|hypot|ldexp|lgamma|log|sin|sinh|sqrt|tan|tanh| )+$/i )

			# Check for stuff from the Math package
			arguments.gsub!(/e/i,        "Math::E")
			arguments.gsub!(/pi/i,       "Math::PI")
			arguments.gsub!(/acos\(/i,   "Math.acos(")
			arguments.gsub!(/acosh\(/i,  "Math.acosh(")
			arguments.gsub!(/asin\(/i,   "Math.asin(")
			arguments.gsub!(/asinh\(/i,  "Math.asinh(")
			arguments.gsub!(/atan\(/i,   "Math.atan(")
			arguments.gsub!(/atan2\(/i,  "Math.atan2(")
			arguments.gsub!(/atanh\(/i,  "Math.atanh(")
			arguments.gsub!(/cbrt\(/i,   "Math.cbrt(")
			arguments.gsub!(/cos\(/i,    "Math.cos(")
			arguments.gsub!(/cosh\(/i,   "Math.cosh(")
			arguments.gsub!(/erfc\(/i,   "Math.erfc(")
			arguments.gsub!(/erf\(/i,    "Math.erf(")
			arguments.gsub!(/frexp\(/i,  "Math.frexp(")
			arguments.gsub!(/exp\(/i,    "Math.exp(")
			arguments.gsub!(/gamma\(/i,  "Math.gamma(")
			arguments.gsub!(/hypot\(/i,  "Math.hypot(")
			arguments.gsub!(/ldexp\(/i,  "Math.ldexp(")
			arguments.gsub!(/lgamma\(/i, "Math.lgamma(")
			arguments.gsub!(/log\(/i,    "Math.log(")
			arguments.gsub!(/log10\(/i,  "Math.log10(")
			arguments.gsub!(/log2\(/i,   "Math.log2(")
			arguments.gsub!(/sin\(/i,    "Math.sin(")
			arguments.gsub!(/sinh\(/i,   "Math.sinh(")
			arguments.gsub!(/sqrt\(/i,   "Math.sqrt(")
			arguments.gsub!(/tan\(/i,    "Math.tan(")
			arguments.gsub!(/tanh\(/i,   "Math.tanh(")

			# Try the calculation
			begin
				result = eval( arguments )
			rescue Exception => e
				@irc.message( from, "Does not seem to be a valid expression. (#{e.message.gsub!(/\n/, '')})" )
				return
			end

			# Return result
			@irc.message( from, "Result: #{result}" )
		else
			@irc.message( from, "Expression contains illegal characters." )			
		end
	end

	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin allows you to do some math.",
			"  calc 5*5         - Do some calculation.",
			"",
			" Allowed operators/functions/constants:",
			"  0..9              numbers. You'll need some.",
			"  .                 decimal point.",
			"  +                 add",
			"  -                 subtract",
			"  *                 multiply",
			"  /                 divide",
			"  %                 Modulo",
			"  **                Exponent",
			"  ()                parentheses",
			"  E                 e (constant)",
			"  PI                pi (constant)",
			"  acos(x)           arc cosine of x. Returns 0..PI.",
			"  acosh(x)          inverse hyperbolic cosine of x.",
			"  asin(x)           arc sine of x. Returns -{PI/2} .. {PI/2}.",
			"  asinh(x)          inverse hyperbolic sine of x.",
			"  atan(x)           arc tangent of x. Returns -{PI/2} .. {PI/2}.",
			"  atan2(y, x)       arc tangent given y and x. Returns -PI..PI.",
			"  atanh(x)          inverse hyperbolic tangent of x.",
			"  cbrt(numeric)     cube root of numeric.",
			"  cos(x)            cosine of x (expressed in radians). Returns -1..1.",
			"  cosh(x)           hyperbolic cosine of x (expressed in radians).",
			"  erf(x)            error function of x.",
			"  erfc(x)           complementary error function of x.",
			"  exp(x)            e**x.",
			"  frexp(numeric)    Returns a two-element array containing the normalized fraction (a Float) and exponent (a Fixnum) of numeric.",
			"  gamma(x)          gamma function of x.",
			"  hypot(x, y)       sqrt(x**2 + y**2), the hypotenuse of a right-angled triangle with sides x and y.",
			"  ldexp(flt, int)   value of flt*(2**int).",
			"  lgamma(x)         logarithmic gamma of x and the sign of gamma of x.",
			"  log(numeric)      natural logarithm of numeric. If additional second argument is given, it will be the base of logarithm.",
			"  log(numeric,base) same as above.",
			"  log10(numeric)    base 10 logarithm of numeric.",
			"  log2(numeric)     base 2 logarithm of numeric.",
			"  sin(x)            sine of x (expressed in radians). Returns -1..1.",
			"  sinh(x)           hyperbolic sine of x (expressed in radians).",
			"  sqrt(x)           non-negative square root of numeric.",
			"  tan(x)            tangent of x (expressed in radians).",
			"  tanh(x)           hyperbolic tangent of x (expressed in radians)."
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
end
