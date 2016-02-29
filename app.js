var fs = require('fs');
var http = require('http');
var express = require('express');
var httpProxy = require('http-proxy');

var proxy = httpProxy.createProxyServer({});
var shadertoyjson = JSON.parse(fs.readFileSync('shadertoy.json'));

var app = express();

process.on('uncaughtException', function(error) {
	console.error(error)
});


app.get('/', function(req, res){
	res.sendfile('index.html');
})

app.get('/view/:filename', function(req, res){
	res.header('Content-type', 'text/html');
	res.end(fs.readFileSync('view/' + req.params.filename));
})

app.get('/css/shadertoy.css', function(req, res){
	res.sendfile('shadertoy.css');
})

app.post('/shadertoy', function(req, res){
	res.json(shadertoyjson);
})

app.use(function(req, res, next) {
	proxy.web(req, res, {
		target: 'http://www.shadertoy.com/'
	});
})

app.listen(18080);

