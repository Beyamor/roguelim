DIRECTION_COMMANDS = {
		'north':	'north',
		'n':		'north',
		'up':		'north',
		'east':		'east',
		'e':		'east',
		'right':	'east',
		'south':	'south',
		's':		'south',
		'down':		'south',
		'west':		'west',
		'w':		'west',
		'left':		'west'
		}

WAIT_COMMANDS	= ['wait']
VIEW_COMMANDS	= ['view', 'v']

def read(s):
	return s.strip().lower()

def do_direction_action(dungeon, direction):
	player = dungeon.player
	if player.can_do_direction_action(direction):
		player.do_direction_action(direction)
		dungeon.update()
		return str(dungeon)
	else:
		return "Can't move " + direction + "\n" + str(dungeon)

def wait(dungeon):
	dungeon.update()
	return str(dungeon)

def process(command, dungeon):
	if command in DIRECTION_COMMANDS:
		direction = DIRECTION_COMMANDS[command]
		return do_direction_action(dungeon, direction)
	elif command in WAIT_COMMANDS:
		return wait(dungeon)
	elif command in VIEW_COMMANDS:
		return str(dungeon)
	else:
		return "Unrecognized command: " + command
