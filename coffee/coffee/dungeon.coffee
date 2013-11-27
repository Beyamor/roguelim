util	= require './util.js'
random	= require './random.js'

DUNGEON_WIDTH		= 10
DUNGEON_HEIGHT		= 10
DUNGEON_XS		= [0...DUNGEON_WIDTH]
DUNGEON_YS		= [0...DUNGEON_HEIGHT]
DIRECTIONS		= ['north', 'east', 'south', 'west']
DIRECTION_DELTAS	=
	north:	[0, -1]
	east:	[1, 0]
	south:	[0, 1]
	west:	[-1, 0]

class Tile
	constructor: (@glyph, @isPassable) ->

	render: ->
		@glyph

WALL_TILE	= new Tile "#", false
FLOOR_TILE	= new Tile "=", true

class Item
	constructor: (@glyph) ->

	render: ->
		@glyph

class Gold extends Item
	constructor: (@value) ->
		super "%"

	onTouch: (entity) ->
		entity.gold += @value
		@cell.removeItem()

		entity.sendMessage random.choice [
			"You picked up #{@value} gold, #{random.choice ["scrilla", "chedda", "bling"]}",
			"#{@value} in the bank, yo"
		]

class Weapon extends Item
	constructor: (@attack) ->
		super "t"
		@description = "+#{@attack} weapon"
		
	onTouch: (entity) ->
		entity.sendMessage "You see a #{@description}"
exports.Weapon = Weapon
	
class Armor extends Item
	constructor: (@defense) ->
		super "k"
		@description = "+#{@defense} armor"

	onTouch: (entity) ->
		entity.sendMessage "You see some #{@description}"
exports.Armor = Armor

class Cell
	constructor: (@dungeon, @x, @y, @tile) ->

	render: ->
		if @entity?
			@entity.render()
		else if @item?
			@item.render()
		else
			@tile.render()

	relative: (direction) ->
		[dx, dy]	= DIRECTION_DELTAS[direction]
		relX		= @x + dx
		relY		= @y + dy

		return null if relX < 0 or relX >= DUNGEON_WIDTH or
				relY < 0 or relY >= DUNGEON_HEIGHT

		return @dungeon.cells[relX][relY]

	addItem: (item) ->
		throw new Error "Cell already has an item" if @item?
		@item		= item
		item.cell	= this

	removeItem: ->
		if @item?
			@item.cell	= null
			@item		= null

	@properties
		isPassable:
			get: ->
				@tile.isPassable and not @entity?

class Entity
	constructor: (@glyph, opts) ->
		@isAlive	= true
		@messages	= []
		@hp		= opts.hp or 1
		@baseAttack	= opts.attack or 1
		@name		= opts.name
		@team		= opts.team

	actionsInDirection: (direction) ->
		actions		= {}
		targetCell	= @cell.relative direction

		if targetCell?
			if targetCell.entity? and targetCell.entity.team isnt @team
				actions.attack = targetCell.entity
			if targetCell.isPassable
				actions.move = targetCell

		return actions

	performAction: (actions) ->
		if actions.attack?
			@attack actions.attack
		else if actions.move
			@dungeon.move this, actions.move

	performActionInDirection: (direction) ->
		@performAction(@actionsInDirection direction)

	sendMessage: (message) ->
		@messages.push message

	clearMessages: ->
		@messages = []

	attack: (target) ->
		damage = @baseAttack
		if @weapon?
			damage += @weapon.attack
		target.hit this, damage

	hit: (attacker, damage) ->
		if @amor?
			damage = Math.max 0, damage - @armor.defense

		if damage isnt 0
			@hp -= damage
			if @hp <= 0 and @isAlive
				@hp = 0
				@kill()
				attacker.sendMessage random.choice [
					"Dang, you rocked #{@name}'s world",
					"#{@name} is down for the count",
					"Snap, you cold murdered #{@name}"
				]
				@sendMessage random.choice [
					"Whoa, #{attacker.name} killed you",
					"#{attacker.name} killed you, that's messed up",
					"Dude, #{attacker.name} schooled you"
				]

			else if @isAlive
				attacker.sendMessage random.choice [
					"You whacked #{attacker.name} for #{damage} damage",
					"You laid #{damage} points of pain on #{@name}"
				]
				@sendMessage random.choice [
					"#{attacker.name} hit your face for #{damage} damage",
					"#{attacker.name} whooped you for #{damage} damage"
				]
		else
			attacker.sendMessage random.choice [
				"You did no damage to #{@name}. #{random.choice ["Uh oh", "Oh boy", "Better run"]}"
			]
			@sendMessage random.choice [
				"#{attacker.name} did no damage. Lolz"
			]

	kill: ->
		return unless @isAlive

		@isAlive = false
		@onDeath() if @onDeath?
		@dungeon.remove this

	update: ->
		# do nothing

	render: ->
		@glyph

	@properties
		dungeon:
			get: -> @cell.dungeon

class Player extends Entity
	constructor: () ->
		super "@",
			hp: 10
			attack: 1
			name: "Player"
			team: "player"
		@gold = 0

	onMove: ->
		item = @cell.item
		if item? and item.onTouch?
			item.onTouch this

class Enemy extends Entity
	constructor: () ->
		super "E",
			name: "Enemy"
			team: "enemy"

	update: ->
		@performActionInDirection random.choice DIRECTIONS
		@clearMessages()

	onDeath: ->
		@cell.addItem random.choice [
			new Gold random.choice [1, 1, 1, 2, 2, 3],
			new Weapon random.choice [1, 1, 2, 2],
			new Armor random.choice [1, 1, 2]
		]
	
class exports.Dungeon
	constructor: () ->
		@entities = []
		@cells = []
		for x in DUNGEON_XS
			@cells.push []
			for y in DUNGEON_YS
				tile = random.choice [WALL_TILE, FLOOR_TILE, FLOOR_TILE, FLOOR_TILE]
				@cells[x].push new Cell this, x, y, tile

		@player = new Player
		@add @player
		@placeOnFreeCell @player

		for i in [0...3]
			enemy = new Enemy
			@add enemy
			@placeOnFreeCell enemy

	placeOnFreeCell: (entity) ->
		@move entity, @getFreeCell()

	move: (entity, newCell) ->
		if newCell? and newCell.entity?
			throw new Error "Cell already has an entity"

		if entity.cell?
			entity.cell.entity = null

		if newCell?
			newCell.entity = entity

		entity.cell = newCell
		entity.onMove() if entity.onMove?

	getFreeCell: ->
		freeCells = []
		for x in DUNGEON_XS
			for y in DUNGEON_YS
				cell = @cells[x][y]
				if cell.isPassable
					freeCells.push cell

		if freeCells.length is 0
			throw new Error "No free cells available"
		return random.choice freeCells

	add: (entity) ->
		@entities.push entity

	remove: (entity) ->
		if entity.cell
			entity.cell.entity	= null
			entity.cell		= null
		@entities.remove entity

	update: ->
		for entity in @entities.clone
			entity.update()

	render: ->
		s = "hp: #{@player.hp} g: #{@player.gold}\n"

		for y in DUNGEON_YS
			for x in DUNGEON_XS
				s += @cells[x][y].render()
			s += "\n" unless y is DUNGEON_HEIGHT - 1

		return s
