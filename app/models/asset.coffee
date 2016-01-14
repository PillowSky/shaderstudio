'use strict'

mongoose = require('../services/mongoose')

AssetSchema = new mongoose.Schema({
	id: Number
	type: String
	src: mongoose.Schema.Types.Mixed
})

module.exports = mongoose.model('Asset', AssetSchema)
