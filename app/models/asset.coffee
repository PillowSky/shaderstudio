'use strict'

mongoose = require('../services/mongoose')

AssetSchema = new mongoose.Schema({
	_id: mongoose.Schema.ObjectId
	id: Number
	type: String
	src: mongoose.Schema.Types.Mixed
})

module.exports = mongoose.model('Asset', AssetSchema)
