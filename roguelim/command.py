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

def read(s):
	return s.strip().lower()

def try_moving_player(dungeon, direction):
	player = dungeon.player
	if dungeon.can_move(player, direction):
		dungeon.move(player, direction)
		dungeon.update()
		return str(dungeon)
	else:
		return "Can't move " + direction + "\n" + str(dungeon)

def process(command, dungeon):
	if command in DIRECTION_COMMANDS:
		direction = DIRECTION_COMMANDS[command]
		return try_moving_player(dungeon, direction)
	elif command == "wait":
		dungeon.update()
		return str(dungeon)
	else:
		return "Unrecognized command: " + command
