exports.read = (s) ->
	s.trim().toLowerCase()

exports.process = (command, dungeon) ->
	dungeon.render()
