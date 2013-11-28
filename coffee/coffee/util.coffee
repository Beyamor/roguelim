Function::properties = (descriptions) ->
	for prop, desc of descriptions
		Object.defineProperty @prototype, prop, desc

Array::remove = (el) ->
	index = @indexOf el
	return unless index >= 0
	@splice index, 1
	return el

Array::contains = (el) ->
	@indexOf(el) isnt -1

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

exports.directionBetween = (start, end) ->
	dx = end.x - start.x
	dy = end.y - start.y

	if dx is 0 and dy < 0
		"north"
	else if dx > 0 and dy is 0
		"east"
	else if dx is 0 and dy > 0
		"south"
	else if dx < 0 and dy is 0
		"west"
	else
		throw new Exception "No direction for #{dx}, #{dy}"
