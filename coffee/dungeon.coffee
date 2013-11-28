{Player}	= require './entities.js'
{Level}		= require './levels.js'
{construct: constructLevel}	= require './levels/construction.js'

class exports.Dungeon
	constructor: ({@enemyNames}) ->
		@player	= new Player

	start: ->
		@depth	= 1
		@level	= new Level this, @player
		constructLevel @level

	exitLevel: ->
		++@depth
		@level = new Level this, @player
		constructLevel @level

	update: ->
		@level.update()

	render: ->
		s = "hp:#{@player.hp} g:#{@player.gold} l:#{@depth}\n"
		s += @level.render()
		return s
