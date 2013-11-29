random	= require './random.js'
util	= require './util.js'
mixins	= require './mixins.js'
items	= require './items.js'

DIRECTIONS	= util.DIRECTIONS

class Entity
	constructor: (@glyph, opts) ->
		@isAlive	= true
		@messages	= []
		@hp		= opts.hp or 1
		@name		= opts.name
		@team		= opts.team

		@mixins		= []
		mixinNames	= opts.mixins or []
		for name in mixinNames
			mixin = mixins.get name
			mixins.apply mixin, this
			@mixins.push mixin

		for mixin in @mixins
			mixin.initialize.call(this) if mixin.initialize?

	actionsInDirection: (direction) ->
		actions		= {}
		targetCell	= @cell.relative direction

		if targetCell?
			enemy = targetCell.entity
			if enemy? and enemy.is('defender') and enemy.team isnt @team and this.is('attacker')
				actions.attack = enemy
			if targetCell.isPassable
				actions.move = targetCell

		return actions

	performAction: (actions) ->
		if actions.attack?
			@hit actions.attack
		else if actions.move
			@level.move this, actions.move

	performActionInDirection: (direction) ->
		@performAction(@actionsInDirection direction)

	kill: ->
		return unless @isAlive

		@isAlive = false
		@onDeath() if @onDeath?
		@level.remove this

	update: ->
		for mixin in @mixins
			mixin.update.call this if mixin.update?

	render: ->
		@glyph

	is: (name) ->
		for mixin in @mixins
			return true if mixin.name is name
		return false

	@properties
		level:
			get: -> @cell.level

class exports.Player extends Entity
	constructor: () ->
		super "0",
			hp: Infinity#10
			name: "Player"
			team: "player"
			mixins: [
				'attacker'
				'defender'
				'messageReceiver'
				'goldHolder'
			]

		@weapon = new items.Weapon.create()

	onMove: ->
		numberOfItems = @cell.items.length
		if numberOfItems is 1
			@sendMessage "You see an item"
		else if numberOfItems > 1
			@sendMessage "You see some items"

		if @cell.exit?
			@sendMessage "You found the exit"

class exports.Enemy extends Entity
	constructor: (name) ->
		super "9",
			name: name
			team: "enemy"
			mixins: ['attacker', 'defender']

	update: ->
		super()

		if @level.player? and @level.player.isAlive
			pathToPlayer = @level.path @cell, @level.player.cell,
				(cell) =>
					if cell.tile.isPassable
						if cell.entity?
							100 # still try, but, like, don't go this way if you can help it
						else
							1
					else
						Infinity

		if pathToPlayer? and pathToPlayer.length <= 5
			[firstCell, secondCell] = pathToPlayer
			direction = util.directionBetween firstCell, secondCell
		else
			direction = random.choice util.DIRECTIONS
		@performActionInDirection direction

	onDeath: ->
		@cell.addItem random.choice [
			new items.Gold(random.choice [1, 1, 1, 2, 2, 3])
			new items.Weapon.create()
			new items.Armor.create()
		]
