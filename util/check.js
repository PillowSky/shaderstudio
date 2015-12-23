'use strict';

var request = require('request');
var MongoClient = require('mongodb').MongoClient;
var assert = require('assert');
var async = require('async');

var mongoUrl = 'mongodb://localhost:27017/shaderstudio';
var syncUrl = 'http://shaderstudio.duapp.com/import';

MongoClient.connect(mongoUrl, function(error, db) {
	assert.equal(null, error);
	console.log("Connected to #{mongoUrl}");

	db.collection('shader').find().toArray(function(error, docs) {
		assert.equal(null, error);
		var srcs = []
		docs.forEach(function (shader) {
			if (shader.Shader.renderpass[0].inputs.length) {
				shader.Shader.renderpass[0].inputs.forEach(function (preset) {
					if (preset.src[0] != '/') {
						console.log(shader.Shader.info.id, preset.src, shader._id);
						//srcs.push(preset.src);
					}
				});
			}
		});
		db.close();
		//console.log(srcs);
	});
});



