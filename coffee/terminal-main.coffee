command		= require './command.js'
{Dungeon}	= require './dungeon.js'
fs		= require 'fs'

stdin	= process.stdin
stdout	= process.stdout

dungeon = new Dungeon
		enemyNames: ["Red", "Blue", "Green", "Yellow"]

reloadDungeon = (cb) ->
	json = dungeon.toJSON()
	fs.writeFile '/tmp/dungeon.json', JSON.stringify(json), (err) ->
		if err?
			console.log "Error writing:"
			console.log err
		else
			fs.readFile '/tmp/dungeon.json', (err, json) ->
				if err?
					console.log "Error reading:"
					console.log err
				else
					dungeon = Dungeon.read JSON.parse(json)
					cb()

dungeon.start()
stdout.write dungeon.render()
stdout.write "\n"

stdin.resume()
stdin.setEncoding 'utf8'
stdin.on 'data', (chunk) ->
	reloadDungeon ->
		stdout.write dungeon.render()
		stdout.write "\n"
	#stdout.write command.process(command.read(chunk), dungeon)
	#stdout.write "\n"
