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

	def on_touch(self, entity):
		pass

class Gold(Item):
	def __init__(self, value):
		Item.__init__(self, "%")
		self.value	= value
		self.cell	= None

	def on_touch(self, entity):
		entity.gold = entity.gold + self.value
		self.cell.remove_item()
		entity.send_message(random.choice([
			"You picked up {0} gold, {1}".format(self.value, random.choice([
				"scrilla",
				"chedda",
				"bling"
				])),
			"{0} in the bank, yo".format(self.value)
			]))

class Weapon(Item):
	def __init__(self, attack):
		Item.__init__(self, "t")
		self.attack = attack

	def on_touch(self, entity):
		entity.send_message("You see a +{0} weapon".format(self.attack))

class Armor(Item):
	def __init__(self, defense):
		Item.__init__(self, "k")
		self.defense = defense

	def on_touch(self, entity):
		entity.send_message("You see some +{0} armor".format(self.defense))

class Cell:
	def __init__(self, dungeon, x, y, tile):
		self.dungeon	= dungeon
		self.x		= x
		self.y		= y
		self.tile	= tile
		self.entity	= None
		self.item	= None

	def __str__(self):
		if self.entity:
			return str(self.entity)
		elif self.item:
			return str(self.item)
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
		self.item	= item
		item.cell	= self

	def remove_item(self):
		if self.item:
			self.item.cell	= None
			self.item	= None

	@property
	def is_passable(self):
		return self.tile.is_passable and self.entity is None


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
		self.weapon		= None
		self.armor		= None

	def __str__(self):
		return self.glyph

	def update(self):
		pass

	def actions_in_direction(self, direction):
		actions		= {}
		target_cell	= self.cell.relative(direction)
		if target_cell:
			if target_cell.entity and target_cell.entity.team != self.team:
				actions['attack'] = target_cell.entity
			if target_cell.is_passable:
				actions['move'] = target_cell
		return actions

	def perform_action(self, actions):
		if not actions:
			return

		if 'attack' in actions:
			self.attack(actions['attack'])
		elif 'move' in actions:
			self.dungeon.move(self, actions['move'])

	def perform_action_in_direction(self, direction):
		self.perform_action(self.actions_in_direction(direction))

	def send_message(self, message, *args):
		self.messages.append(message.format(*args))

	def attack(self, target):
		damage = self.base_attack
		if self.weapon:
			damage = damage + self.weapon.attack
		target.hit(self, damage)

	def hit(self, attacker, damage):
		if self.armor:
			damage = max(0, self.armor.defense)

		if damage is not 0:
			self.hp = self.hp - damage
			if self.hp <= 0 and self.is_alive:
				self.hp = 0
				self.kill()
				attacker.send_message(random.choice([
						"Dang, you rocked {0}'s world".format(self.name),
						"{0} is down for the count".format(self.name),
						"Snap, you cold murdered {0}".format(self.name)
					]))
				self.send_message(random.choice([
						"Whoa, {0} killed you".format(attacker.name),
						"{0} killed you, that's messed up".format(attacker.name),
						"Dude, {0} schooled you.".format(attacker.name)
					]))
			else:
				attacker.send_message(random.choice([
					"You whacked {0} for {1} damage".format(self.name, damage),
					"You laid {0} points of pain on {1}".format(damage, self.name)
					]))
				self.send_message(random.choice([
					"{0} hit your face for {1} damage".format(attacker.name, damage),
					"{0} whooped you for {1} damage".format(attacker.name, damage)
					]))
		else:
			attacker.send_message(random.choice([
				"You did no damage to {0}. {1}".format(self.name, random.choice([
						"Uh oh",
						"Oh boy",
						"Better run"
					]))
				]))
			self.send_message(random.choice([
				"{0} did no damage. Lolz".format(attacker.name)
				]))

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
		item = self.cell.item
		if item:
			item.on_touch(self)
			
class Enemy(Entity):
	def __init__(self):
		Entity.__init__(self, "E", name="Enemy", team="enemy")

	def update(self):
		self.perform_action_in_direction(random.choice(DIRECTIONS))
		self.messages = [] # who cares

	def on_death(self):
		self.cell.add_item(random.choice([
				#Gold(random.choice([1, 1, 1, 2, 2, 3])),
				Weapon(random.choice([1, 1, 2, 2])),
				Armor(random.choice([1, 1, 2]))
			]))

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
