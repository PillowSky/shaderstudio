'use strict'

mongoose = require('../services/mongoose')

CommentSchema = new mongoose.Schema({
	shader: String
	comments: [{
		username: String
		comment: String
		date: {type: Date, default: Date.now}
	}]
})

module.exports = mongoose.model('Comment', CommentSchema)
