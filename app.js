require('coffee-script/register');

var express = require('express');
var config = require('./config/config');

var app = express();
require('./config/express')(app, config);

if (require.main == module) {
	app.listen(config.port, function () {
		console.log('Express server listening on port ' + this.address().port);
	});
} else {
	module.exports = app;
}
