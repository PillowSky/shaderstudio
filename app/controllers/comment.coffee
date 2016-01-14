'use strict'

Comment = require('../models/comment')

module.exports = (app) ->
	app.get '/comment/:shaderId', (req, res, next) ->
		Comment.findOne {shader: req.params.shaderId}, (error, doc)->
			return next(new Error(error)) if error

			res.send(doc)

	app.post '/comment/:shaderId', (req, res, next)->
		comment =
			username: req.cookies.user.username
			comment: req.body.comment

		Comment.findOneAndUpdate({shader: req.params.shaderId}, {$addToSet: {comments: comment}}, {upsert: true}).exec (error, doc)->
			console.log(error, doc)
			res.end()
