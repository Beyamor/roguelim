util		= require './util.js'
random		= require './random.js'
entities	= require './entities.js'

exports.LEVEL_WIDTH	= LEVEL_WIDTH		= 10
exports.LEVEL_HEIGHT	= LEVEL_HEIGHT		= 10
LEVEL_XS		= [0...LEVEL_WIDTH]
LEVEL_YS		= [0...LEVEL_HEIGHT]
DIRECTION_DELTAS	= util.DIRECTION_DELTAS

class Tile
	constructor: (@glyph, @isPassable) ->

	render: ->
		@glyph

exports.WALL_TILE	= WALL_TILE	= new Tile "#", false
exports.FLOOR_TILE	= FLOOR_TILE	= new Tile "~", true

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

		return null if relX < 0 or relX >= LEVEL_WIDTH or
				relY < 0 or relY >= LEVEL_HEIGHT

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

class exports.Level
	constructor: () ->
		@entities = []
		@cells = []
		for x in LEVEL_XS
			@cells.push []
			for y in LEVEL_YS
				@cells[x].push new Cell this, x, y, WALL_TILE

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

	eachCell: (f) ->
		for x in LEVEL_XS
			for y in LEVEL_YS
				f x, y, @cells[x][y]

	getFreeCell: ->
		freeCells = []
		@eachCell (x, y, cell) ->
			freeCells.push(cell) if cell.isPassable

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
		s = ""
		for y in LEVEL_YS
			for x in LEVEL_XS
				s += @cells[x][y].render()
			s += "\n" unless y is LEVEL_HEIGHT - 1

		return s
