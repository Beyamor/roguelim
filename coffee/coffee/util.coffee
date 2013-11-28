Function::properties = (descriptions) ->
	for prop, desc of descriptions
		Object.defineProperty @prototype, prop, desc

Array::remove = (el) ->
	index = @indexOf el
	return unless index >= 0
	@splice index, 1
	return el

Object.defineProperty Array.prototype, 'clone'
	get: -> @concat()

exports.isEmptyObject = (obj) ->
	for prop of obj
		return false if obj.hasOwnProperty prop
	return true

exports.DIRECTIONS = ['north', 'east', 'south', 'west']
exports.DIRECTION_DELTAS =
	north:	[0, -1]
	east:	[1, 0]
	south:	[0, 1]
	west:	[-1, 0]

exports.log = (s) ->
	process.stdout.write "#{s}\n"
