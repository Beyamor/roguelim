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
