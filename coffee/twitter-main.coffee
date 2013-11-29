Twit		= require "twit"
config		= require "./twitter-config.js"
c		= require './command.js'
{Dungeon}	= require './dungeon.js'
fs		= require 'fs'

TWITTER_NAME	= "@#{config.account}"

twitter		= new Twit config
myTweets	= twitter.stream 'user', with: 'user'
myTweets.on "tweet", (tweet) ->
	user = tweet.user.screen_name
	return unless user isnt config.account
	console.log "tweet by @#{user}: #{tweet.text}"

	text = tweet.text
	return unless text.substring(0, TWITTER_NAME.length).toLowerCase() is TWITTER_NAME.toLowerCase()
	text = text.substring TWITTER_NAME.length

	dungeonPath = "users/#{user}/dungeon"

	respond = (response) ->
		twitter.post 'statuses/update', {status: "@#{user}\n#{response}"},
			(err, reply) ->
				if err?
					console.log err

	readDungeon = ->
		fd = fs.openSync dungeonPath, "r"
		[json, _] = fs.readSync fd, 8000, 0
		fs.closeSync fd
		console.log "read dungeon from #{dungeonPath}"
		return Dungeon.read JSON.parse(json)

	writeDungeon = (dungeon) ->
		fd = fs.openSync dungeonPath, "w"
		fs.writeSync fd, JSON.stringify(dungeon.toJSON())
		fs.closeSync fd
		console.log "wrote dungeon to #{dungeonPath}"

	console.log "text is #{text}"
	command = c.read text

	if command[0] is "start"
		console.log "starting"

		fs.mkdirSync "users" unless fs.existsSync "users"
		fs.mkdirSync "users/#{user}" unless fs.existsSync "users/#{user}"

		twitter.get 'friends/list', {screen_name: user, count:200}, (err, {users: friends}) ->
			if err?
				console.log err
			else
				dungeon = new Dungeon
					enemyNames: (name for {screen_name: name} in friends)
				dungeon.start()

				writeDungeon dungeon
				respond c.process ["show", "dungeon"], dungeon
	else
		console.log "processing #{command[0]}"

		started	= fs.existsSync dungeonPath
		if started
			dungeon	= readDungeon()

			result		= c.process command, dungeon
			response	= "#{result}"

			writeDungeon dungeon
			respond response
		else
			respond "No dungeon in progress! Try the `start` command"
