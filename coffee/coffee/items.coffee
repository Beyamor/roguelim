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

		entity.sendMessage random.choice [
			"You picked up #{@value} gold, #{random.choice ["scrilla", "chedda", "bling"]}",
			"#{@value} in the bank, yo"
		]

class exports.Weapon extends Item
	constructor: (@attack) ->
		super "t"
		@description = "+#{@attack} weapon"
		
	onTouch: (entity) ->
		entity.sendMessage "You see a #{@description}"
	
class exports.Armor extends Item
	constructor: (@defense) ->
		super "k"
		@description = "+#{@defense} armor"

	onTouch: (entity) ->
		entity.sendMessage "You see some #{@description}"
