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
			attack: 1

	hit: (target) ->
		damage = @attack
		if @weapon? and @weapon.attack?
			damage += @weapon.attack
		if @armor? and @armor.attack?
			damage += @armor.attack
		target.takeHit this, damage

defmixin 'defender',
	takeHit: (attacker, damage) ->
		if @armor? and @armor.defense?
			damage = Math.max 0, damage - @armor.defense
		if @weapon? and @weapon.defense?
			damage = Math.max 0, damage - @weapon.defense

		@hp -= damage
		if attacker.is 'messageReceiver'
			attacker.sendMessage "You did #{damage} damage to #{@name}"
		if this.is 'messageReceiver'
			@sendMessage "#{attacker.name} did #{damage} damage to you"

		if @hp <= 0 and this.isAlive
			@hp = 0
			@kill()
			if attacker.is 'messageReceiver'
				attacker.sendMessage "You killed #{@name}"
			if this.is 'messageReceiver'
				@sendMessage "#{attacker.name} killed you"

defmixin 'messageReceiver',
	initialize: ->
		@messages = []

	clearMessages: ->
		@messages = []

	sendMessage: (message) ->
		@messages.push message

defmixin 'goldHolder',
	initialize: ->
		defaults this, gold: 0
