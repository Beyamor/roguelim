command	= require './command.js'
d	= require './dungeon.js'
stdin	= process.stdin
stdout	= process.stdout

dungeon = new d.Dungeon
stdout.write dungeon.render()

stdin.resume()
stdin.setEncoding 'utf8'
stdin.on 'data', (chunk) ->
	stdout.write command.process(command.read(chunk), dungeon)
