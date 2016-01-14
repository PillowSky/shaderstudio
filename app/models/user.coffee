'use strict'

bcrypt = require('bcrypt')
mongoose = require('../services/mongoose')

UserSchema = new mongoose.Schema({
	email: String
	username: String
	password: String
})

UserSchema.statics.hash = (password, callback)->
	bcrypt.hash(password, 10, callback)

UserSchema.statics.compare = (password, hash, callback)->
	bcrypt.compare(password, hash, callback)

module.exports = mongoose.model('User', UserSchema)
