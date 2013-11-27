import random

DUNGEON_WIDTH		= 10
DUNGEON_HEIGHT		= 10
DUNGEON_XS		= range(DUNGEON_WIDTH)
DUNGEON_YS		= range(DUNGEON_HEIGHT)
DIRECTIONS		= ['north', 'east', 'south', 'west']
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
	def __init__(self, dungeon, x, y, tile):
		self.dungeon	= dungeon
		self.x		= x
		self.y		= y
		self.tile	= tile
		self.entity	= None

	def __str__(self):
		if self.entity:
			return str(self.entity)
		else:
			return str(self.tile)

	def relative(self, direction):
		(dx, dy)	= DIRECTION_DELTAS[direction]
		relx		= self.x + dx
		rely		= self.y + dy

		if relx < 0 or relx >= DUNGEON_WIDTH or rely < 0 or rely >= DUNGEON_HEIGHT:
			return None
		return self.dungeon.cells[relx][rely]

	def update(self):
		if self.entity:
			self.entity.update()

	@property
	def is_passable(self):
		return self.tile.is_passable and self.entity is None

class Entity:
	def __init__(self, glyph, hp=1):
		self.glyph	= glyph
		self.cell	= None
		self.hp		= hp
		self.is_alive	= True

	def __str__(self):
		return self.glyph

	def update(self):
		pass

	def can_do_direction_action(self, direction):
		target_cell = self.cell.relative(direction)
		if target_cell:
			return target_cell.entity or target_cell.is_passable
		else:
			return False

	def do_direction_action(self, direction):
		if not self.can_do_direction_action(direction):
			raise Exception("Can't do direction action")

		target_cell = self.cell.relative(direction)

		# first, try attacking
		if target_cell.entity:
			self.attack(target_cell.entity)
		else:
			self.dungeon.move(self, target_cell)

	def attack(self, target):
		target.hit(1)

	def hit(self, damage):
		self.hp = self.hp - damage
		if self.hp <= 0 and self.is_alive:
			self.kill()

	def kill(self):
		self.is_alive = False
		self.dungeon.remove(self)

	@property
	def dungeon(self):
		return self.cell.dungeon

class Player(Entity):
	def __init__(self):
		Entity.__init__(self, "@")

class Enemy(Entity):
	def __init__(self):
		Entity.__init__(self, "E")

	def update(self):
		direction	= random.choice(DIRECTIONS)
		target_cell	= self.cell.relative(direction)
		if target_cell and target_cell.is_passable:
			self.dungeon.move(self, target_cell)

class Dungeon:
	def __init__(self):
		self.cells	= [[None for y in DUNGEON_YS] for x in DUNGEON_XS]
		for x in DUNGEON_XS:
			for y in DUNGEON_YS:
				tile = random.choice([WALL_TILE, FLOOR_TILE, FLOOR_TILE, FLOOR_TILE])
				self.cells[x][y] = Cell(self, x, y, tile)

		self.player = Player()
		self.place_on_free_cell(self.player)

		for i in range(3):
			enemy = Enemy()
			self.place_on_free_cell(enemy)

	def place_on_free_cell(self, entity):
		self.move(entity, self.get_free_cell())

	def move(self, entity, new_cell):
		if new_cell and new_cell.entity:
			raise Exception("Cell already has an entity")

		if entity.cell:
			entity.cell.entity = None

		entity.cell = new_cell

		if new_cell:
			new_cell.entity = entity

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

	def remove(self, entity):
		if entity.cell:
			entity.cell.entity	= None
			entity.cell		= None

	def update(self):
		for x in DUNGEON_XS:
			for y in DUNGEON_YS:
				self.cells[x][y].update()

	def __str__(self):
		s = ""
		for y in DUNGEON_YS:
			for x in DUNGEON_XS:
				s = s + str(self.cells[x][y])

			if y < DUNGEON_HEIGHT - 1:
				s = s + "\n"
		return s
