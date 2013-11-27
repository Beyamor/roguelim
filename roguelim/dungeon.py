import random

DUNGEON_WIDTH		= 10
DUNGEON_HEIGHT		= 10
DUNGEON_XS		= range(DUNGEON_WIDTH)
DUNGEON_YS		= range(DUNGEON_HEIGHT)
DIRECTION_DELTAS	= {
		"north":	(0, -1),
		"east":		(1, 0),
		"south":	(0, 1),
		"west":		(-1, 0)
		}

class Tile:
	def __init__(self, glyph, is_passable):
		self.glyph		= glyph
		self.is_passable	= is_passable

	def __str__(self):
		return self.glyph

WALL_TILE	= Tile("#", False)
FLOOR_TILE	= Tile("=", True)

class Cell:
	def __init__(self, x, y, tile):
		self.x		= x
		self.y		= y
		self.tile	= tile
		self.entity	= None

	def __str__(self):
		if self.entity:
			return str(self.entity)
		else:
			return str(self.tile)

	@property
	def is_passable(self):
		return self.tile.is_passable

class Player:
	def __init__(self):
		self.cell = None

	def __str__(self):
		return "@"

class Dungeon:
	def __init__(self):
		self.cells	= [[None for y in DUNGEON_YS] for x in DUNGEON_XS]
		for x in DUNGEON_XS:
			for y in DUNGEON_YS:
				tile = random.choice([WALL_TILE, FLOOR_TILE])
				self.cells[x][y] = Cell(x, y, tile)

		self.player = Player()
		self.place_on_free_cell(self.player)

	def place(self, entity, cell):
		if cell.entity:
			raise Exception("Cell already has an entity")

		cell.entity	= entity
		entity.cell	= cell

	def place_on_free_cell(self, entity):
		self.place(entity, self.get_free_cell())

	def can_move(self, entity, direction):
		(dx, dy)	= DIRECTION_DELTAS[direction]
		newX		= entity.cell.x + dx
		newY		= entity.cell.y + dy

		if newX < 0 or newX >= DUNGEON_WIDTH or newY < 0 or newY >= DUNGEON_HEIGHT:
			return False

		return self.cells[newX][newY].is_passable

	def move(self, entity, direction):
		if not self.can_move(entity, direction):
			raise Exception("Can't move entity ({0}, {1}) {2}".format(entity.cell.x, entity.cell.y, direction))

		(dx, dy)	= DIRECTION_DELTAS[direction]
		new_cell	= self.cells[entity.cell.x + dx][entity.cell.y + dy]

		entity.cell.entity	= None
		entity.cell		= new_cell
		new_cell.entity		= entity

	def get_free_cell(self):
		free_cells = []
		for x in DUNGEON_XS:
			for y in DUNGEON_YS:
				cell = self.cells[x][y]
				if cell.is_passable:
					free_cells.append(cell)

		if len(free_cells) is 0:
			raise Exception("No free cells available")
		return random.choice(free_cells)

	def __str__(self):
		s = ""
		for y in DUNGEON_YS:
			for x in DUNGEON_XS:
				s = s + str(self.cells[x][y])

			if y < DUNGEON_HEIGHT - 1:
				s = s + "\n"
		return s
