import random

DUNGEON_WIDTH	= 10
DUNGEON_HEIGHT	= 10
FLOOR_TILE	= "="
WALL_TILE	= "#"

def create_dungeon():
	dungeon = [[None for y in range(DUNGEON_HEIGHT)] for x in range(DUNGEON_WIDTH)]
	for x in range(DUNGEON_WIDTH):
		for y in range(DUNGEON_HEIGHT):
			dungeon[x][y] = random.choice([WALL_TILE, FLOOR_TILE])

	return dungeon

def dungeon_string(dungeon):
	s = ""
	for y in range(DUNGEON_HEIGHT):
		for x in range(DUNGEON_WIDTH):
			s = s + dungeon[x][y]

		if y < DUNGEON_HEIGHT - 1:
			s = s + "\n"
	return s

def main():
	print(dungeon_string(create_dungeon()))

if __name__ == "__main__":
	main()
