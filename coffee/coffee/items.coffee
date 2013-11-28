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
		@cell.removeItem()

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
			minAttack: 1
			maxAttack: 2
			defense: 1
	
class exports.Armor extends Item
	constructor: (@defense) ->
		super "k"
		@description = "+#{@defense} armor"

	onTouch: (entity) ->
		entity.sendMessage "You see some #{@description}"
