'use strict'

mongoose = require('../services/mongoose')

AssetSchema = new mongoose.Schema({
	_id: mongoose.Schema.ObjectId
	path: String
})

module.exports = mongoose.model('Asset', AssetSchema)
