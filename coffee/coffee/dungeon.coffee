util		= require './util.js'
random		= require './random.js'
entities	= require './entities.js'

DUNGEON_WIDTH		= 10
DUNGEON_HEIGHT		= 10
DUNGEON_XS		= [0...DUNGEON_WIDTH]
DUNGEON_YS		= [0...DUNGEON_HEIGHT]
DIRECTION_DELTAS	= util.DIRECTION_DELTAS

class Tile
	constructor: (@glyph, @isPassable) ->

	render: ->
		@glyph

WALL_TILE	= new Tile "#", false
FLOOR_TILE	= new Tile "=", true

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

		return null if relX < 0 or relX >= DUNGEON_WIDTH or
				relY < 0 or relY >= DUNGEON_HEIGHT

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

class exports.Dungeon
	constructor: () ->
		@entities = []
		@cells = []
		for x in DUNGEON_XS
			@cells.push []
			for y in DUNGEON_YS
				tile = random.choice [WALL_TILE, FLOOR_TILE, FLOOR_TILE, FLOOR_TILE]
				@cells[x].push new Cell this, x, y, tile

		@player = new entities.Player
		@add @player
		@placeOnFreeCell @player

		for i in [0...3]
			enemy = new entities.Enemy
			@add enemy
			@placeOnFreeCell enemy

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

	getFreeCell: ->
		freeCells = []
		for x in DUNGEON_XS
			for y in DUNGEON_YS
				cell = @cells[x][y]
				if cell.isPassable
					freeCells.push cell

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
		s = "hp: #{@player.hp} g: #{@player.gold}\n"

		for y in DUNGEON_YS
			for x in DUNGEON_XS
				s += @cells[x][y].render()
			s += "\n" unless y is DUNGEON_HEIGHT - 1

		return s
