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

def get_result(dungeon):
	result = str(dungeon)
	for message in dungeon.player.messages:
		result = result + "\n" + message
	dungeon.player.messages = []
	return result

def updated_dungeon(dungeon):
	dungeon.update()
	return get_result(dungeon)

def do_direction_action(dungeon, direction):
	player = dungeon.player
	if player.can_do_direction_action(direction):
		player.do_direction_action(direction)
		return updated_dungeon(dungeon)
	else:
		return "Can't move " + direction + "\n" + str(dungeon)

def wait(dungeon):
	return updated_dungeon(dungeon)

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
