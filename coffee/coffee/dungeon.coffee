{Player}	= require './entities.js'
{Level}		= require './levels.js'

class exports.Dungeon
	constructor: ->
		@player	= new Player

		@level	= new Level
		@level.add @player
		@level.placeOnFreeCell @player

	update: ->
		@level.update()

	render: ->
		s = "hp: #{@player.hp} g: #{@player.gold}\n"
		s += @level.render()
		return s
