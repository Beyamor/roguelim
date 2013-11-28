{Player}	= require './entities.js'
{Level}		= require './levels.js'
{construct: constructLevel}	= require './levels/construction.js'

class exports.Dungeon
	constructor: ->
		@player	= new Player

		@level	= new Level this, @player
		constructLevel @level

	update: ->
		@level.update()

	render: ->
		s = "hp: #{@player.hp} g: #{@player.gold}\n"
		s += @level.render()
		return s
