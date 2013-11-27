import random

DUNGEON_WIDTH	= 10
DUNGEON_HEIGHT	= 10
DUNGEON_XS	= range(DUNGEON_WIDTH)
DUNGEON_YS	= range(DUNGEON_HEIGHT)

class Tile:
	def __init__(self, glyph, is_passable):
		self.glyph		= glyph
		self.is_passable	= is_passable

	def __str__(self):
		return self.glyph

WALL_TILE	= Tile("#", False)
FLOOR_TILE	= Tile("=", True)

class Cell:
	def __init__(self, tile):
		self.tile	= tile
		self.entity	= None

	def __str__(self):
		if self.entity:
			return str(self.entity)
		else:
			return str(self.tile)

	def is_passable(self):
		return self.tile.is_passable

class Player:
	def move_to(self, cell):
		if cell.entity is not None:
			raise "Cell already has an entity"
		cell.entity = self

	def __str__(self):
		return "@"

class Dungeon:
	def __init__(self):
		self.cells	= [[None for y in DUNGEON_YS] for x in DUNGEON_XS]
		for x in DUNGEON_XS:
			for y in DUNGEON_YS:
				tile = random.choice([WALL_TILE, FLOOR_TILE])
				self.cells[x][y] = Cell(tile)

		player_cell = self.get_free_cell()
		player = Player()
		player.move_to(player_cell)

	def get_free_cell(self):
		free_cells = []
		for x in DUNGEON_XS:
			for y in DUNGEON_YS:
				cell = self.cells[x][y]
				if cell.is_passable():
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

def main():
	dungeon = Dungeon()
	print(str(dungeon))

if __name__ == "__main__":
	main()
