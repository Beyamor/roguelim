random	= require './random.js'

class Item
	constructor: (@glyph) ->

	render: ->
		@glyph

class exports.Gold extends Item
	constructor: (@value) ->
		super "$"

	onTouch: (entity) ->
		if entity.is 'goldHolder'
			entity.gold += @value
			@cell.removeItem this

			if entity.is "messageReceiver"
				entity.sendMessage "You picked up #{@value} gold"

	toJSON: ->
		type:	"gold"
		value:	@value

class exports.Weapon extends Item
	constructor: ({@minAttack, @maxAttack, @defense}) ->
		super "1"

		if @minAttack isnt @maxAttack
			@description = "#{@minAttack}-#{@maxAttack}"
		else
			@description = "#{@minAttack}"
		@description += "str"
		if @defense? and @defense isnt 0
			@description += " #{@defense}def"
		@description += " sword"
		
	@properties
		attack:
			get: -> random.intInRange @minAttack, (@maxAttack + 1)

	@create: ->
		new exports.Weapon
			minAttack:	random.choice [1, 1, 2]
			maxAttack:	random.choice [2, 2, 3]
			defense:	random.choice [0, 0, 1]

	toJSON: ->
		type:		'weapon'
		minAttack:	@minAttack
		maxAttack:	@maxAttack
		defense:	@defense
	
class exports.Armor extends Item
	constructor: ({@defense, @attack}) ->
		super "4"
		@description = ""
		if @attack? and @attack isnt 0
			@description += "#{@attack}str "
		@description += "#{@defense}def armor"

	@create: ->
		new exports.Armor
			defense:	random.choice [1, 1, 2]
			attack:		random.choice [0, 0, 1]

	toJSON: ->
		type:		'armor'
		defense:	@defense
		attack:		@attack
