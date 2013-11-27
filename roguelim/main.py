from dungeon import Dungeon

DIRECTION_COMMANDS = {
		'north':	'north',
		'up':		'north',
		'east':		'east',
		'right':	'east',
		'south':	'south',
		'down':		'south',
		'west':		'west',
		'left':		'west'
		}

def main():
	dungeon = Dungeon()
	while True:
		line	= raw_input()
		command	= line.lower().strip()

		if command in DIRECTION_COMMANDS:
			direction = DIRECTION_COMMANDS[command]
			print("Moving " + direction)
			print(dungeon)
		else:
			print("Unrecognized command: " + command)

if __name__ == "__main__":
	main()
