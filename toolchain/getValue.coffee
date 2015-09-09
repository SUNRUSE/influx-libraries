# Given:
#	The platform instance.
#	The input value object.
#	A string containing the starting value of an expression.
#	The function containing the expression.
#	Optionally, an array of strings.  This will be written to log attempts to
#		match functions.
#	When the fourth argument is given, a prefix to prepend onto to log lines
#		generated by child expressions and functions.
#   The cache object, as described in "findFunction".
# Returns:
#	When the starting value could not be resolved, falsy.
#	When the starting value is a primitive literal, a value object containing
#	the primitive.
#	When the starting value is "input", the input value object.
#	When the starting value is the name of a temporary variable, the result of
#	compileExpression for that temporary variable. 

module.exports = (platform, input, token, funct, log, logPrefix, cache) ->
	if token is "input"
		if log
			log.push logPrefix + "Initial value is the input." 
		return input
	for primitive of platform.primitives
		value = platform.primitives[primitive].parse token
		if value isnt undefined
			if log
				log.push logPrefix + "Initial value is the literal \"" + token + "\" of primitive type \"" + primitive + "\"." 
			return unused =
				score: 0
				primitive:
					type: primitive
					value: value
	if funct.declarations[token]
		if log
			log.push logPrefix + "Attempting to compile declaration \"" + token + "\"..." 
		return module.exports.compileExpression platform, input, funct.declarations[token], funct, log, logPrefix + "\t", cache
	if log
		log.push logPrefix + "Failed to resolve initial value \"" + token + "\"." 
	return
		
module.exports.compileExpression = require "./compileExpression"