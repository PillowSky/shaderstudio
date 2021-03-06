'use strict'

mongoose = require('../services/mongoose')

InfoSchema = new mongoose.Schema({
	id: String
	date: {type: Date, default: Date.now}
	viewed: Number
	name: String
	username: String
	description: String
	likes: Number
	published: Number
	flags: Number
	tags: [String]
	hasliked: Number
})

SamplerSchema = new mongoose.Schema({
	filter: String
	wrap: String
	vflip: String
	srgb: String
	internal: String
})

InputSchema = new mongoose.Schema({
	id: Number
	src: mongoose.Schema.Types.Mixed
	ctype: String
	channel: Number
	sampler: SamplerSchema
})

OutputSchema = new mongoose.Schema({
	channel: Number
})

RenderPassSchema = new mongoose.Schema({
	inputs: [InputSchema]
	outputs: [OutputSchema]
	code: String
	name: String
	description: String
	type: String
})

ShaderSchema = new mongoose.Schema({
	ver: String
	info: InfoSchema
	renderpass: [RenderPassSchema]
})

ShaderSchema.statics.get = (shaderId, callback)->
	@findOne({'info.id': shaderId}, callback)

ShaderSchema.statics.query = (criteria, sort, skip, limit, callback)->
	@find(criteria).sort(sort).skip(skip).limit(limit).exec(callback)

ShaderSchema.statics.queryId = (criteria, sort, callback)->
	@find(criteria, {'info.id': 1, _id: 0}).sort(sort).exec (error, docs)->
		callback error, docs.map (doc)->
			doc.info.id

ShaderSchema.statics.allId = (callback)->
	@find({}, {'info.id': 1, _id: 0}).exec (error, docs)->
		callback error, docs.map (doc)->
			doc.info.id

module.exports = mongoose.model('Shader', ShaderSchema)
