util		= require './util'
random		= require './random'
entities	= require './entities'
items		= require './items'

exports.LEVEL_WIDTH	= LEVEL_WIDTH		= 8
exports.LEVEL_HEIGHT	= LEVEL_HEIGHT		= 6
LEVEL_XS		= [0...LEVEL_WIDTH]
LEVEL_YS		= [0...LEVEL_HEIGHT]
DIRECTION_DELTAS	= util.DIRECTION_DELTAS

class Tile
	constructor: (@glyph, @isPassable) ->

	render: ->
		@glyph

	toJSON: ->
		glyph:		@glyph
		isPassable:	@isPassable

	@read: (json) ->
		new Tile json.glyph, json.isPassable

exports.WALL_TILE	= WALL_TILE	= new Tile "#", false
exports.FLOOR_TILE	= FLOOR_TILE	= new Tile "~", true

class Cell
	constructor: (@level, @x, @y, @tile) ->
		@items = []

	render: ->
		if @entity?
			@entity.render()
		else if @items.length isnt 0
			@items[@items.length-1].render()
		else if @exit?
			">"
		else
			@tile.render()

	relative: (direction) ->
		[dx, dy]	= DIRECTION_DELTAS[direction]
		relX		= @x + dx
		relY		= @y + dy

		return null if relX < 0 or relX >= LEVEL_WIDTH or
				relY < 0 or relY >= LEVEL_HEIGHT

		return @level.cells[relX][relY]

	addItem: (item) ->
		needsToBeAdded  = true
		if item instanceof items.Gold
			for existingItem in @items
				if existingItem instanceof items.Gold
					existingItem.value += item.value
					needsToBeAdded = false
					break

		if needsToBeAdded
			@items.push item = item
			item.cell = this

	removeItem: (item) ->
		@items.remove item
		item.cell = null

	@properties
		isPassable:
			get: ->
				@tile.isPassable and not @entity?

	toJSON: ->
		tile:	@tile.toJSON()
		items:	(item.toJSON() for item in @items)
		exit:	@exit

	@read: (json, level, x, y) ->
		cell		= new Cell level, x, y, Tile.read(json.tile)
		cell.exit	= json.exit
		cell.items	= (items.read itemJSON for itemJSON in json.items)
		item.cell	= cell for item in cell.items
		return cell

class exports.Level
	constructor: (@dungeon, @player) ->
		@entities = []
		@cells = []
		for x in LEVEL_XS
			@cells.push []
			for y in LEVEL_YS
				@cells[x].push new Cell this, x, y, WALL_TILE

	placeOnFreeCell: (entity) ->
		@place entity, @getFreeCell()

	# move, but, like, without the callbacks
	place: (entity, newCell) ->
		if newCell? and newCell.entity?
			throw new Error "Cell already has an entity"

		if entity.cell?
			entity.cell.entity = null

		if newCell?
			newCell.entity = entity

		entity.cell = newCell

	move: (entity, newCell) ->
		@place entity, newCell
		if newCell?
			for item in newCell.items.clone
				if item.onTouch?
					item.onTouch entity
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

	path: (start, end, weighting) ->
		open	= [cell: start]
		closed	= []

		addNeighbours = (node) =>
			for direction, delta of util.DIRECTION_DELTAS
				[dx, dy]	= delta
				neighbourX	= node.cell.x + dx
				neighbourY	= node.cell.y + dy

				continue unless	neighbourX >= 0 and
						neighbourX < LEVEL_WIDTH and
						neighbourY >= 0 and
						neighbourY < LEVEL_HEIGHT

				neighbourCell = @cells[neighbourX][neighbourY]

				continue if weighting(neighbourCell) is Infinity

				alreadyClosed = false
				for closedNode in closed
					if closedNode.cell is neighbourCell
						alreadyClosed = true
						break
				continue if alreadyClosed

				alreadyOpen = false
				for openNode in open
					if openNode.cell is neighbourCell
						alreadyOpen = true
						if g(node) < g(openNode.parent)
							openNode.parent = node
						break
				continue if alreadyOpen

				open.push
					cell: neighbourCell
					parent: node

		g = (node) ->
			result = weighting node.cell
			if node.parent?
				result += g(node.parent)
			return result

		h = (node) ->
			dx = end.x - node.cell.x
			dy = end.y - node.cell.y
			return Math.abs(dx) + Math.abs(dy)

		while true
			return null unless open.length > 0 # no path possible

			minF		= Infinity
			nextNode	= null
			for node in open
				f = g(node) + h(node)
				if f < minF
					minF		= f
					nextNode	= node

			open.remove nextNode
			closed.push nextNode

			if nextNode.cell is end
				finalNode = nextNode
				break
			else
				addNeighbours nextNode

		path = []
		pathNode = finalNode
		while pathNode?
			path.unshift pathNode.cell
			pathNode = pathNode.parent
		return path

	toJSON: ->
		cells = []
		for x in LEVEL_XS
			cells.push []
			for y in LEVEL_YS
				cells[x].push @cells[x][y].toJSON()

		cells:		cells
		entities:	(entity.toJSON() for entity in @entities)


	@read = (json, dungeon) ->
		level = new Level dungeon

		for x in LEVEL_XS
			for y in LEVEL_YS
				level.cells[x][y] = Cell.read json.cells[x][y], level, x, y

		for entityJSON in json.entities
			entity = entities.read entityJSON
			level.add entity

			{x, y} = entityJSON
			if x? and y?
				level.place entity, level.cells[x][y]

			if entityJSON.type is "player"
				level.player = entity

		return level
