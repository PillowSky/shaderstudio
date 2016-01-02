'use strict'

$ ->
	$('.masthead').visibility
		once: false
		onBottomPassed: ->
			$('.fixed.menu').transition 'fade in'
		onBottomPassedReverse: ->
			$('.fixed.menu').transition 'fade out'

	# create sidebar and attach to menu open
	$('.ui.sidebar').sidebar 'attach events', '.toc.item'
	$('.ui.search').search()

	gl = twgl.getWebGLContext(document.querySelector('#home'))

	imagePass = null
	imagePassTexturesConfig = {}
	imagePassChannelResolution = new Float32Array(12)

	#TODO: soundPass
	for pass in window.shader.renderpass
		switch pass.type
			when 'image'
				if imagePass
					console.log("Pass ignored: #{pass.type}", pass)
				else
					imagePass = pass
			else
				console.log("Pass ignored: #{pass.type}", pass)

	#TODO: imagePass: music, video, webcam, mic, keyboard
	#TODO: soundPass: texture
	headCode = $('#head').text()
	imagePass.inputs.forEach (input)->
		switch input.ctype
			when 'texture', 'cubemap'
				textureConfig = {}

				if input.ctype == 'texture'
					textureConfig.src = window.config['asset.host'] + input.src
				else
					headCode = headCode.replace("sampler2D #{'iChannel' + input.channel}", "samplerCube #{'iChannel' + input.channel}")
					textureConfig.target = gl.TEXTURE_CUBE_MAP
					textureConfig.src = input.src.map (src)->
						window.config['asset.host'] + src

				switch input.sampler.filter
					when 'nearest'
						textureConfig.filter = gl.NEAREST
					when 'linear'
						textureConfig.filter = gl.LINEAR
					when 'mipmap'
						textureConfig.filter = gl.LINEAR_MIPMAP_LINEAR
					else
						console.log("Unexpected filter: #{input.sampler.filter}", input)

				switch input.sampler.wrap
					when 'clamp'
						textureConfig.wrap = gl.CLAMP_TO_EDGE
					when 'repeat'
						textureConfig.wrap = gl.REPEAT
					else
						console.log("Unexpected wrap: #{input.sampler.wrap}", input)

				switch input.sampler.vflip
					when 'true'
						textureConfig.flipY = true
					when 'false'
						textureConfig.flipY = false
					else
						console.log("Unexpected vflip: #{input.sampler.vflip}", input)

				imagePassTexturesConfig['iChannel' + input.channel] = textureConfig
			else
				console.log("Input ignored: #{input.ctype}", input)

	imagePassTextures = twgl.createTextures gl, imagePassTexturesConfig, (error, texs, imgs)->
		if error
			console.error(error)
		else
			imagePass.inputs.forEach (input)->
				switch input.ctype
					when 'texture', 'cubemap'
						imagePassChannelResolution[input.channel * 3] = imgs['iChannel' + input.channel].width
						imagePassChannelResolution[input.channel * 3 + 1] = imgs['iChannel' + input.channel].height
					else
						console.log("Input ignored again: #{input.ctype}", input)

	programInfo = twgl.createProgramInfo(gl, ['pass', headCode + imagePass.code])

	bufferInfo = twgl.createBufferInfoFromArrays(gl, {
		position: {
			numComponents: 2,
			data: [
				1.0, 1.0,
				-1.0, 1.0,
				1.0, -1.0,
				-1.0, -1.0
			]
		}
	})

	mouse = new Float32Array(4)
	$('#home').mousedown ->
		base = $(this).offset()
		mouse[2] = event.pageX - base.left
		mouse[3] = event.pageY - base.top

		$(this).mousemove (event)->
			offset = $(this).offset()
			mouse[0] = event.pageX - offset.left
			mouse[1] = event.pageY - offset.top

	$('#home').mouseup ->
		$(this).unbind('mousemove')

	render = (time)->
		twgl.resizeCanvasToDisplaySize(gl.canvas);
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height)

		#TODO: iChannelTime
		d = new Date()
		uniforms =
			iResolution: [gl.canvas.width, gl.canvas.height, 0]
			iGlobalTime: time / 1000
			iChannelTime: [0, 0, 0, 0]
			iChannelResolution: imagePassChannelResolution
			iMouse: mouse
			iDate: [d.getFullYear(), d.getMonth(), d.getDate(), d.getHours()*3600 + d.getMinutes()*60 + d.getSeconds() + d.getMilliseconds()/1000]
			iSampleRate: 441000

		for channelName in imagePassTextures
			uniforms[channelName] = imagePassTextures[channelName]

		twgl.setUniforms(programInfo, uniforms)
		twgl.drawBufferInfo(gl, gl.TRIANGLE_STRIP, bufferInfo)

		requestAnimationFrame(render)

	gl.useProgram(programInfo.program)
	twgl.setBuffersAndAttributes(gl, programInfo, bufferInfo)
	requestAnimationFrame(render)
