command	= require './command.js'
d	= require './dungeon.js'
stdin	= process.stdin
stdout	= process.stdout

dungeon = new d.Dungeon
dungeon.start()
stdout.write dungeon.render()
stdout.write "\n"

stdin.resume()
stdin.setEncoding 'utf8'
stdin.on 'data', (chunk) ->
	stdout.write command.process(command.read(chunk), dungeon)
	stdout.write "\n"
