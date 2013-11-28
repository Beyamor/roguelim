Twit	= require "twit"
config	= require "./twitter-config.js"
command	= require './command.js'
d	= require './dungeon.js'

TWITTER_NAME	= "@#{config.account}"

dungeon = new d.Dungeon
		enemyNames: ["Red", "Blue", "Yellow", "Green"]
dungeon.start()

twitter		= new Twit config
myTweets	= twitter.stream 'user', with: 'user'
myTweets.on "tweet", (tweet) ->
	return unless tweet.user.screen_name isnt config.account

	text = tweet.text
	return unless text.substring(0, TWITTER_NAME.length) is TWITTER_NAME
	text = text.substring TWITTER_NAME.length

	result = command.process(command.read(text), dungeon)
	response = "@#{tweet.user.screen_name}\n#{result}"
	twitter.post 'statuses/update', {status: response}, (err, reply) ->
		# do nothing
