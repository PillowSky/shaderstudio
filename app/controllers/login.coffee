'use strict'

User = require('../models/user')

module.exports = (app) ->
	app.get '/login', (req, res) ->
		res.render('login')

	app.post '/login', (req, res)->
		User.findOne {username: req.body.username}, (error, user)->
			if error
				res.render('login', {error: error})
			else if not user
				res.render('login', {error: 'User not found'})
			else
				User.compare req.body.password, user.password, (error, success)->
					if error
						res.render('login', {error: error})
					else if not success
						res.render('login', {error: 'Invalid password'})
					else
						res.cookie('user', user, {expires: new Date(Date.now() + 86400)})
						res.redirect('/')
