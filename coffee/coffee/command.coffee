util	= require './util.js'
items	= require './items.js'

DIRECTION_COMMANDS =
	north:	'north'
	n:	'north'
	up:	'north'
	east:	'east'
	e:	'east'
	right:	'east'
	south:	'south'
	s:   	'south'
	down:	'south'
	west:	'west'
	w:   	'west'
	left:	'west'

exports.read = (s) ->
	s.trim().toLowerCase()

renderUpdate = (dungeon) ->
	s = dungeon.render()
	for message in dungeon.player.messages
		s += "\n" + message
	dungeon.player.clearMessages()
	return s

updatedDungeon = (dungeon) ->
	dungeon.update()
	return renderUpdate dungeon

doDirectionAction = (dungeon, direction) ->
	player		= dungeon.player
	possibleActions	= player.actionsInDirection direction

	if not util.isEmptyObject possibleActions
		player.performAction possibleActions
		return updatedDungeon dungeon
	else
		return "Can't move #{direction}"

wait = (dungeon) ->
	return updatedDungeon dungeon

showPlayer = ({player}) ->
	s = ""
	s += "hp: #{player.hp}"
	s += "\ng: #{player.gold}"
	s += "\nw: #{if player.weapon? then player.weapon.description else "None"}"
	s += "\na: #{if player.armor? then player.armor.description else "None"}"

equip = (dungeon) ->
	player	= dungeon.player
	item	= player.cell.item

	if item? and item instanceof items.Weapon
		oldWeapon = player.weapon
		item.cell.removeItem()
		player.weapon = item
		if oldWeapon?
			player.cell.addItem oldWeapon
		return updatedDungeon dungeon

	else if item? and item instanceof items.Armor
		oldArmor = player.armor
		item.cell.removeItem()
		player.armor = item
		if oldArmor?
			player.cell.addItem oldArmor
		return updatedDungeon dungeon

	else
		return "Nothing to equip"

exit = (dungeon) ->
	if dungeon.player.cell.exit?
		dungeon.exitLevel()
		return dungeon.render()
	else
		return "No exit"

exports.process = (command, dungeon) ->
	if DIRECTION_COMMANDS[command]?
		direction = DIRECTION_COMMANDS[command]
		return doDirectionAction dungeon, direction
	else if command is "wait"
		return wait(dungeon)
	else if command is "look"
		return dungeon.render()
	else if command is "player"
		return showPlayer(dungeon)
	else if command is "equip"
		return equip(dungeon)
	else if command is "exit"
		return exit(dungeon)
	else
		return "Unrecognized command: #{command}"
