{Player}	= require './entities.js'
{Level}		= require './levels.js'
{construct: constructLevel}	= require './levels/construction.js'

class exports.Dungeon
	constructor: ({@enemyNames, @depth}) ->
		@player	= new Player
		@depth or= 1

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
		s = "hp:#{@player.hp} g:#{@player.gold}\n"
		s += @level.render()
		return s

	toJSON: ->
		depth:		@depth
		level:		@level.toJSON()
		enemyNames:	@enemyNames

	@read: (json) ->
		dungeon			= new Dungeon json
		dungeon.level		= Level.read json.level, dungeon
		dungeon.player		= dungeon.level.player
		return dungeon
