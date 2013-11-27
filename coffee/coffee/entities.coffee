random	= require './random.js'
util	= require './util.js'
items		= require './items.js'

DIRECTIONS	= util.DIRECTIONS

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

class exports.Player extends Entity
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

class exports.Enemy extends Entity
	constructor: () ->
		super "E",
			name: "Enemy"
			team: "enemy"

	update: ->
		@performActionInDirection random.choice DIRECTIONS
		@clearMessages()

	onDeath: ->
		@cell.addItem random.choice [
			new items.Gold(random.choice [1, 1, 1, 2, 2, 3]),
			new items.Weapon(random.choice [1, 1, 2, 2]),
			new items.Armor(random.choice [1, 1, 2])
		]
