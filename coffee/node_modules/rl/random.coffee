exports.intInRange = (args...) ->
	if args.length is 1
		exports.intInRange 0, args[0]
	else if args.length is 2
		[min, max] = args
		return Math.floor(min + Math.random() * (max - min))

exports.choice = (coll) ->
	index = exports.intInRange coll.length
	return coll[index]
