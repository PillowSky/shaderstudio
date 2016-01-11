'use strict'

$ ->
	imageRender = null
	soundRender = null

	createShader = ->
		window.shader.renderpass.forEach (pass)->
			switch pass.type
				when 'image'
					if not imageRender
						imageRender = new ImageRender(
							document.querySelector('#canvas')
							$('#canvas'),
							$('body'),
							$('#glslVert').text(),
							$('#glslImage').text(),
							pass,
							window.config['asset.host']
						)
					else
						console.log("Pass ignored: #{pass.type}", pass)

				when 'sound'
					if not soundRender
						soundRender = new SoundRender(
							document.createElement('canvas'),
							null
							null,
							$('#glslVert').text(),
							$('#glslSound').text(),
							pass,
							window.config['asset.host']
						)
					else
						console.log("Pass ignored: #{pass.type}", pass)
				else
					console.log("Pass ignored: #{pass.type}", pass)

	startShader = ->
		imageRender?.start()
		soundRender?.start()

	stopShader = ->
		imageRender?.stop()
		soundRender?.stop()

	destroyShader = ->
		imageRender = null
		soundRender = null

	setTimeout ->
		createShader()
		startShader()
		window.imageRender = imageRender
		window.soundRender = soundRender
	, 0

	editor = ace.edit("editor");
	editor.setTheme("ace/theme/twilight");
	editor.session.setMode("ace/mode/glsl");

