command	= require './command.js'
d	= require './dungeon.js'
fs	= require 'fs'
stdin	= process.stdin
stdout	= process.stdout

dungeon = new d.Dungeon
		enemyNames: ["Red", "Blue", "Green", "Yellow"]
dungeon.start()
stdout.write dungeon.render()
stdout.write "\n"

json = dungeon.toJSON()
fs.writeFile '/tmp/dungeon.json', JSON.stringify(json), (err) ->
	console.log err if err?

stdin.resume()
stdin.setEncoding 'utf8'
stdin.on 'data', (chunk) ->
	stdout.write command.process(command.read(chunk), dungeon)
	stdout.write "\n"
