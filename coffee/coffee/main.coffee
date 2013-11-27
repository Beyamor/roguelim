process.stdin.on 'data', (chunk) ->
	process.stdout.write "You wrote #{chunk}"
