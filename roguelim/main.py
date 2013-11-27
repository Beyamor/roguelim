import random

DUNGEON_WIDTH	= 10
DUNGEON_HEIGHT	= 10

class Tile:
	def __init__(self, glyph):
		self.glyph = glyph

	def __str__(self):
		return self.glyph

WALL_TILE	= Tile("=")
FLOOR_TILE	= Tile("#")

class Dungeon:
	def __init__(self):
		self.tiles = [[None for y in range(DUNGEON_HEIGHT)] for x in range(DUNGEON_WIDTH)]
		for x in range(DUNGEON_WIDTH):
			for y in range(DUNGEON_HEIGHT):
				self.tiles[x][y] = random.choice([WALL_TILE, FLOOR_TILE])

	def __str__(self):
		s = ""
		for y in range(DUNGEON_HEIGHT):
			for x in range(DUNGEON_WIDTH):
				s = s + str(self.tiles[x][y])

			if y < DUNGEON_HEIGHT - 1:
				s = s + "\n"
		return s

def main():
	dungeon = Dungeon()
	print(str(dungeon))

if __name__ == "__main__":
	main()
