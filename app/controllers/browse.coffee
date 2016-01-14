'use strict'

Shader = require('../models/shader')
Config = require('../models/config')
Filter = require('../models/filter')

module.exports = (app) ->
	sortMap =
		'view': 'info.viewed'
		'like': 'info.likes'
		'date': 'info.date'

	orderMap =
		'desc': '-'
		'asc': ''

	filterMap =
		'gpusound': 'gpusound'
		'microphone': 'microphone'
		'musicinput': 'musicinput'
		'webcamera': 'webcamera'

	app.get '/browse', (req, res, next) ->
		req.query.keyword ?= ''
		req.query.sort ?= 'view'
		req.query.order ?= 'desc'
		req.query.filter ?= ''

		keyword = req.query.keyword
		sort = sortMap[req.query.sort]
		order = orderMap[req.query.order]
		filter = filterMap[req.query.filter]
		fuzzyQuery = [{'info.name': {$regex: keyword, $options: 'i'}}, {'info.tags': {$elemMatch: {$regex: keyword, $options: 'i'}}}]

		if filter
			Filter.get filter, (error, doc)->
				return next(new Error(error)) if error

				Shader.queryId {'info.id': {$in: doc.value}, $or: fuzzyQuery}, order + sort, (error, docs)->
					return next(new Error(error)) if error

					res.render('browse', {'shaderIds': docs, 'config': Config.config, 'user': req.cookies.user, 'keyword': keyword, 'sort': req.query.sort, 'order': req.query.order, 'filter': req.query.filter})
		else
			Shader.queryId {$or: fuzzyQuery}, order + sort, (error, docs)->
				return next(new Error(error)) if error

				res.render('browse', {'shaderIds': docs, 'config': Config.config, 'user': req.cookies.user, 'keyword': keyword, 'sort': req.query.sort, 'order': req.query.order, 'filter': req.query.filter})
