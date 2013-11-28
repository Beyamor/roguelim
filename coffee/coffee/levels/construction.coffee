random		= require '../random.js'
entities	= require '../entities.js'
{WALL_TILE, FLOOR_TILE} = require '../levels.js'

exports.construct = (level) ->
	level.eachCell (x, y, cell) ->
		cell.tile = random.choice [WALL_TILE, FLOOR_TILE, FLOOR_TILE, FLOOR_TILE]

	for i in [0...3]
		enemy = new entities.Enemy
		level.add enemy
		level.placeOnFreeCell enemy
