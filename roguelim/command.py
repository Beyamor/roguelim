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

def process(command, dungeon):
	if command in DIRECTION_COMMANDS:
		direction = DIRECTION_COMMANDS[command]
		s = "Moving " + direction + "\n"
		s = s + str(dungeon)
		return s
	else:
		return "Unrecognized command: " + command
