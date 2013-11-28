Twit	= require "twit"
config	= require "./twitter-config.js"

twitter		= new Twit config
myTweets	= twitter.stream 'user', with: 'user'
myTweets.on "tweet", (tweet) ->
	return unless tweet.user.screen_name isnt config.account
	console.log tweet
