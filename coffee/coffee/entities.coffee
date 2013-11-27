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
		@baseAttack	= opts.attack or 1
		@name		= opts.name
		@team		= opts.team

		@mixins		= []
		mixinNames	= opts.mixins or []
		for name in mixinNames
			mixin = mixins.get name
			mixins.apply mixin, this
			@mixins.push mixin
		for mixin in @mixins
			mixin.initialize.call this if mixin.initialize?

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

	kill: ->
		return unless @isAlive

		@isAlive = false
		@onDeath() if @onDeath?
		@dungeon.remove this

	update: ->
		for mixin in @mixins
			mixin.update.call this if mixin.update?

	render: ->
		@glyph

	hasMixin: (name) ->
		for mixin in @mixins
			return true if mixin.name is name
		return false

	@properties
		dungeon:
			get: -> @cell.dungeon

class exports.Player extends Entity
	constructor: () ->
		super "@",
			hp: 10
			attack: 1
			name: "Player"
			team: "player"
			mixins: ['attacker', 'defender', 'messageReceiver']
		@gold = 0

	onMove: ->
		item = @cell.item
		if item? and item.onTouch?
			item.onTouch this

class exports.Enemy extends Entity
	constructor: () ->
		super "E",
			name: "Enemy"
			team: "enemy"
			mixins: ['attacker', 'defender']

	update: ->
		@performActionInDirection random.choice DIRECTIONS
		super()

	onDeath: ->
		@cell.addItem random.choice [
			new items.Gold(random.choice [1, 1, 1, 2, 2, 3]),
			new items.Weapon(random.choice [1, 1, 2, 2]),
			new items.Armor(random.choice [1, 1, 2])
		]
