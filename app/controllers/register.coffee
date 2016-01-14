'use strict'

User = require('../models/user')

module.exports = (app) ->
	app.get '/register', (req, res) ->
		res.render('register')

	app.post '/register', (req, res)->
		User.hash req.body.password, (error, encrypted)->
			if error
				res.render('register', {error: error})
			else
				u = new User({email: req.body.email, username: req.body.username, password: encrypted})
				u.save (error)->
					if error
						res.render('register', {error: error})
					else
						res.cookie('user', u, {expires: new Date(Date.now() + 86400)})
						res.redirect('/')
