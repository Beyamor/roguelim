random	= require './random.js'

class Item
	constructor: (@glyph) ->

	render: ->
		@glyph

class exports.Gold extends Item
	constructor: (@value) ->
		super "%"

	onTouch: (entity) ->
		entity.gold += @value
		@cell.removeItem this

		if entity.is "messageReceiver"
			entity.sendMessage "You picked up #{@value} gold"

class exports.Weapon extends Item
	constructor: ({@minAttack, @maxAttack, @defense}) ->
		super "t"

		if @minAttack isnt @maxAttack
			@description = "#{@minAttack}-#{@maxAttack}"
		else
			@description = "#{@minAttack}"
		@description += "str"
		if @defense? and @defense isnt 0
			@description += " #{@defense}def"
		@description += " sword"
		
	onTouch: (entity) ->
		entity.sendMessage "You see a #{@description}"

	@properties
		attack:
			get: -> random.intInRange @minAttack, (@maxAttack + 1)

	@create: ->
		new exports.Weapon
			minAttack:	random.choice [1, 1, 2]
			maxAttack:	random.choice [2, 2, 3]
			defense:	random.choice [0, 0, 1]
	
class exports.Armor extends Item
	constructor: ({@defense, @attack}) ->
		super "k"
		@description = ""
		if @attack? and @attack isnt 0
			@description += "#{@attack}str "
		@description += "#{@defense}def armor"

	onTouch: (entity) ->
		entity.sendMessage "You see some #{@description}"

	@create: ->
		new exports.Armor
			defense:	random.choice [1, 1, 2]
			attack:		random.choice [0, 0, 1]
