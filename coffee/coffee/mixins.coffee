random	= require './random.js'

mixins = {}
defmixin = (name, definition) ->
	definition.name = name
	mixins[name] = definition

exports.get = (name) ->
	mixins[name]

exports.apply = (definition, entity) ->
	if definition.defaults?
		for k, v of definition.defaults
			unless entity[k]?
				entity[k] = v

	for k, v of definition when k isnt 'update' and k isnt 'initialize'
		unless entity[k]?
			entity[k] = v

defaults = (entity, props) ->
	for k, v of props
		unless entity[k]?
			entity[k] = v

defmixin 'attacker',
	initialize: ->
		defaults this,
			baseAttack: 1

	attack: (target) ->
		damage = @baseAttack
		if @weapon?
			damage += @weapon.attack
		target.takeHit this, damage

defmixin 'defender',
	takeHit: (attacker, damage) ->
		if @amor?
			damage = Math.max 0, damage - @armor.defense

		if damage isnt 0
			@hp -= damage
			if @hp <= 0 and this.isAlive
				@hp = 0
				@kill()
				attacker.sendMessage random.choice [
					"Dang, you rocked #{@name}'s world",
					"#{@name} is down for the count",
					"Snap, you cold murdered #{@name}"
				] if attacker.is 'messageReceiver'

				@sendMessage random.choice [
					"Whoa, #{attacker.name} killed you",
					"#{attacker.name} killed you, that's messed up",
					"Dude, #{attacker.name} schooled you"

				] if this.is 'messageReceiver'

			else if this.isAlive
				attacker.sendMessage random.choice [
					"You whacked #{@name} for #{damage} damage",
					"You laid #{damage} points of pain on #{@name}"
				] if attacker.is 'messageReceiver'

				@sendMessage random.choice [
					"#{attacker.name} hit your face for #{damage} damage",
					"#{attacker.name} whooped you for #{damage} damage"
				] if this.is 'messageReceiver'
		else
			attacker.sendMessage random.choice [
				"You did no damage to #{@name}. #{random.choice ["Uh oh", "Oh boy", "Better run"]}"
			] if attacker.is 'messageReceiver'

			@sendMessage random.choice [
				"#{attacker.name} did no damage. Lolz"
			] if this.is 'messageReceiver'

defmixin 'messageReceiver',
	initialize: ->
		@messages = []

	clearMessages: ->
		@messages = []

	sendMessage: (message) ->
		@messages.push message
