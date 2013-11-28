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
	s.trim().toLowerCase().split(/\s+/)

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

equip = (dungeon, which) ->
	player = dungeon.player

	item = player.cell.items[which]
	return "#{which} isn't an option" unless item?

	if item instanceof items.Weapon
		oldWeapon = player.weapon
		item.cell.removeItem item
		player.weapon = item
		if oldWeapon?
			player.cell.addItem oldWeapon
		return updatedDungeon dungeon

	else if item instanceof items.Armor
		oldArmor = player.armor
		item.cell.removeItem item
		player.armor = item
		if oldArmor?
			player.cell.addItem oldArmor
		return updatedDungeon dungeon

	else
		return "Can't equip #{item.description}"

exit = (dungeon) ->
	if dungeon.player.cell.exit?
		dungeon.exitLevel()
		return dungeon.render()
	else
		return "No exit"

help = ->
	"commands: north, south, east, west, wait, look, player, equip {which}, exit, items"

showItems = (dungeon) ->
	cellItems = dungeon.player.cell.items
	return "None" if cellItems.length is 0

	s = ""
	for i in [0...cellItems.length]
		s += "\n" if i isnt 0
		s += "#{i+1}: #{cellItems[i].description}"
	return s

exports.process = ([command, args...], dungeon) ->
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
		if args.length isnt 1
			return "Equip which?"
		else
			which = Number(args[0]) - 1
			return equip(dungeon, which)
	else if command is "items"
		return showItems(dungeon)
	else if command is "exit"
		return exit(dungeon)
	else if command is "help"
		return help()
	else
		return "Unrecognized command: #{command}"
