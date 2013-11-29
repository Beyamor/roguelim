random		= require '../random.js'
util		= require '../util.js'
entities	= require '../entities.js'
{WALL_TILE, FLOOR_TILE, LEVEL_WIDTH, LEVEL_HEIGHT} = require '../levels.js'

MIN_ROOM_DIM	= 1
MAX_ROOM_DIM	= 5

generateRoomPossibilities = ->
	roomPossibilities = []
	for x in [1...LEVEL_WIDTH]
		for y in [1...LEVEL_HEIGHT]
			for width in [MIN_ROOM_DIM..MAX_ROOM_DIM] when x + width < LEVEL_WIDTH
				for height in [MIN_ROOM_DIM..MAX_ROOM_DIM] when y + height < LEVEL_HEIGHT
					roomPossibilities.push
						left:	x
						right:	x + width - 1
						top:	y
						bottom:	y + height - 1
						area:	width * height
	return roomPossibilities

removeOverlappingRooms = (someRoom, allRooms) ->
	for room in allRooms.clone
		continue if	room.right < someRoom.left - 1 or
				room.left > someRoom.right + 1 or
				room.bottom < someRoom.top - 1 or
				room.top > someRoom.bottom + 1

		allRooms.remove room

connect = (from, to, level) ->
	startX	= Math.floor((from.left + from.right) / 2)
	startY	= Math.floor((from.top + from.bottom) / 2)
	start	= level.cells[startX][startY]
	endX	= Math.floor((to.left + to.right) / 2)
	endY	= Math.floor((to.top + to.bottom) / 2)
	end	= level.cells[endX][endY]

	path = level.path start, end,
		(cell) ->
			if cell.tile is WALL_TILE then 4 else 1
	for cell in path
		cell.tile = FLOOR_TILE

exports.construct = (level) ->
	rooms			= []
	roomPossibilities	= generateRoomPossibilities()
	while roomPossibilities.length > 0
		weightedRoomPossibilities = []
		for room in roomPossibilities
			for i in [0...room.area]
				weightedRoomPossibilities.push room
		room = random.choice weightedRoomPossibilities
		rooms.push room
		removeOverlappingRooms room, roomPossibilities

	for room in rooms
		for x in [room.left..room.right]
			for y in [room.top..room.bottom]
				level.cells[x][y].tile = FLOOR_TILE

	for roomIndex in [0...rooms.length]
		firstRoom	= rooms[roomIndex]
		secondRoom	= rooms[(roomIndex + 1) % rooms.length]
		connect firstRoom, secondRoom, level

	playerCell = level.getFreeCell()
	level.add level.player
	level.move level.player, playerCell

	for i in [0...3]
		name = random.choice level.dungeon.enemyNames
		enemy = new entities.Enemy name: name
		level.add enemy
		level.placeOnFreeCell enemy

	possibleExitCells = []
	level.eachCell (x, y, cell) ->
		return unless cell.tile.isPassable
		dx = x - playerCell.x
		dy = y - playerCell.y
		weight = dx*dx + dy*dy
		for i in [0...weight]
			possibleExitCells.push cell

	exitCell = random.choice possibleExitCells
	exitCell.exit = true
