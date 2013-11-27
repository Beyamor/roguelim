command	= require('./command.js')
stdin	= process.stdin
stdout	= process.stdout

stdin.resume()
stdin.setEncoding 'utf8'
stdin.on 'data', (chunk) ->
	stdout.write "command: #{command.read chunk}\n"
