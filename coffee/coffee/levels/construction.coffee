random		= require '../random.js'
util		= require '../util.js'
entities	= require '../entities.js'
{WALL_TILE, FLOOR_TILE, LEVEL_WIDTH, LEVEL_HEIGHT} = require '../levels.js'

MIN_ROOM_DIM	= 2
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

exports.construct = (level) ->
	roomPossibilities = generateRoomPossibilities()
	while roomPossibilities.length > 0
		weightedRoomPossibilities = []
		for room in roomPossibilities
			for i in [0...room.area]
				weightedRoomPossibilities.push room
		room = random.choice weightedRoomPossibilities
		removeOverlappingRooms room, roomPossibilities

		for x in [room.left..room.right]
			for y in [room.top..room.bottom]
				level.cells[x][y].tile = FLOOR_TILE

	for i in [0...3]
		enemy = new entities.Enemy
		level.add enemy
		level.placeOnFreeCell enemy
