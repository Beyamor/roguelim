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
	player			= dungeon.player
	possible_actions	= player.actions_in_direction(direction)
	if possible_actions:
		player.perform_action(possible_actions)
		return updated_dungeon(dungeon)
	else:
		return "Can't move " + direction + "\n" + str(dungeon)

def wait(dungeon):
	return updated_dungeon(dungeon)

def show_player(dungeon):
	player = dungeon.player

	return """hp: {0}
g:  {1}
w:  {2}
a:  {3}""".format(
		player.hp,
		player.gold,
		None,
		None
		)

def process(command, dungeon):
	if command in DIRECTION_COMMANDS:
		direction = DIRECTION_COMMANDS[command]
		return do_direction_action(dungeon, direction)
	elif command == "wait":
		return wait(dungeon)
	elif command == "look":
		return str(dungeon)
	elif command == "player":
		return show_player(dungeon)
	else:
		return "Unrecognized command: " + command
