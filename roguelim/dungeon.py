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

class Item:
	def __init__(self, glyph):
		self.glyph = glyph

	def __str__(self):
		return self.glyph

class Gold(Item):
	def __init__(self, value):
		Item.__init__(self, "%")
		self.value = value

class Cell:
	def __init__(self, dungeon, x, y, tile):
		self.dungeon	= dungeon
		self.x		= x
		self.y		= y
		self.tile	= tile
		self.entity	= None
		self._items	= []

	def __str__(self):
		if self.entity:
			return str(self.entity)
		elif len(self._items) > 0:
			return str(self._items[-1])
		else:
			return str(self.tile)

	def relative(self, direction):
		(dx, dy)	= DIRECTION_DELTAS[direction]
		relx		= self.x + dx
		rely		= self.y + dy

		if relx < 0 or relx >= DUNGEON_WIDTH or rely < 0 or rely >= DUNGEON_HEIGHT:
			return None
		return self.dungeon.cells[relx][rely]

	def add_item(self, item):
		self._items.append(item)

	def remove_item(self, item):
		self._items.remove(item)

	@property
	def is_passable(self):
		return self.tile.is_passable and self.entity is None

	@property
	def items(self):
		return list(self._items)

eid = 0
class Entity:
	def __init__(self, glyph, hp=1, base_attack=1, name="", team=""):
		global eid
		eid = eid + 1

		self.eid		= eid
		self.glyph		= glyph
		self.cell		= None
		self.hp			= hp
		self.is_alive		= True
		self.base_attack	= base_attack
		self.messages		= []
		self.name		= name
		self.team		= team

	def __str__(self):
		return self.glyph

	def update(self):
		pass

	def can_do_direction_action(self, direction):
		target_cell = self.cell.relative(direction)
		if target_cell:
			if target_cell.entity and target_cell.entity.team != self.team:
				return True
			if target_cell.is_passable:
				return True
			return False
		else:
			return False

	def do_direction_action(self, direction):
		if not self.can_do_direction_action(direction):
			raise Exception("Can't do direction action")

		target_cell = self.cell.relative(direction)

		if target_cell.entity and target_cell.entity.team != self.team:
			self.attack(target_cell.entity)
		else:
			self.dungeon.move(self, target_cell)

	def send_message(self, message, *args):
		self.messages.append(message.format(*args))

	def attack(self, target):
		self.send_message("You attacked {0} for {1} damage", target.name, self.base_attack)
		target.hit(self, self.base_attack)

	def hit(self, attacker, damage):
		self.send_message("{0} hit you for {1} damage", attacker.name, damage)
		self.hp = self.hp - damage
		if self.hp <= 0 and self.is_alive:
			self.kill()
			attacker.send_message("You killed {0}", self.name)

	def kill(self):
		if not self.is_alive:
			return

		self.is_alive = False
		self.on_death()
		self.dungeon.remove(self)

	def on_move(self):
		pass

	def on_death(self):
		pass

	@property
	def dungeon(self):
		return self.cell.dungeon

class Player(Entity):
	def __init__(self):
		Entity.__init__(self, "@", hp=10, base_attack=1, name="Player", team="player")
		self.gold = 0

	def on_move(self):
		for item in self.cell.items:
			if isinstance(item, Gold):
				self.cell.remove_item(item)
				self.send_message("You picked up {0} gold", item.value)
				self.gold = self.gold + item.value

class Enemy(Entity):
	def __init__(self):
		Entity.__init__(self, "E", name="Enemy", team="enemy")

	def update(self):
		direction = random.choice(DIRECTIONS)
		if self.can_do_direction_action(direction):
			self.do_direction_action(direction)

		self.messages = [] # who cares

	def on_death(self):
		self.cell.add_item(Gold(random.choice([1, 1, 1, 2, 2, 3])))

class Dungeon:
	def __init__(self):
		self.entities	= []
		self.cells	= [[None for y in DUNGEON_YS] for x in DUNGEON_XS]
		for x in DUNGEON_XS:
			for y in DUNGEON_YS:
				tile = random.choice([WALL_TILE, FLOOR_TILE, FLOOR_TILE, FLOOR_TILE])
				self.cells[x][y] = Cell(self, x, y, tile)

		self.player = Player()
		self.add(self.player)
		self.place_on_free_cell(self.player)

		for i in range(3):
			enemy = Enemy()
			self.add(enemy)
			self.place_on_free_cell(enemy)

	def place_on_free_cell(self, entity):
		self.move(entity, self.get_free_cell())

	def move(self, entity, new_cell):
		if new_cell and new_cell.entity:
			raise Exception("Cell already has an entity")

		if entity.cell:
			entity.cell.entity = None

		if new_cell:
			new_cell.entity = entity

		entity.cell = new_cell
		entity.on_move()

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

	def add(self, entity):
		self.entities.append(entity)

	def remove(self, entity):
		if entity.cell:
			entity.cell.entity	= None
			entity.cell		= None
		self.entities.remove(entity)

	def update(self):
		for entity in list(self.entities):
			entity.update()

	def __str__(self):
		s = "hp: {0} g: {1}\n".format(self.player.hp, self.player.gold)
		for y in DUNGEON_YS:
			for x in DUNGEON_XS:
				s = s + str(self.cells[x][y])

			if y < DUNGEON_HEIGHT - 1:
				s = s + "\n"
		return s
