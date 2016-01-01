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
	soundPass = null

	for pass in window.shader.renderpass
		switch pass.type
			when 'image'
				if imagePass
					console.log("Pass ignored: #{pass.type}", pass)
				else
					imagePass = pass
			when 'sound'
				if soundPass
					console.log("Pass ignored: #{pass.type}", pass)
				else
					soundPass = pass
			else
				console.log("Pass ignored: #{pass.type}", pass)

	imagePass.inputs.forEach (input)->
		switch input.ctype
			when 'texture'
				textureConfig =
					'src': window.config['asset.host'] + input.src

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

				imagePassTexturesConfig['ichannel' + input.channel] = textureConfig
			else
				console.log("Input ignored: #{input.ctype}", input)

	imagePassTextures = twgl.createTextures gl, imagePassTexturesConfig, (error, texs, imgs)->
		if error
			console.error(error)
		else
			imagePass.inputs.forEach (input)->
				switch input.ctype
					when 'texture'
						imagePassChannelResolution[input.channel * 3] = imgs['ichannel' + input.channel].width
						imagePassChannelResolution[input.channel * 3 + 1] = imgs['ichannel' + input.channel].height
					else
						console.log("Input ignored again: #{input.ctype}", input)

	programInfo = twgl.createProgramInfo(gl, ['pass', $('#head').text() + imagePass.code])

	arrays = {
		position: {
			numComponents: 2,
			data: [
				1.0, 1.0,
				-1.0, 1.0,
				1.0, -1.0,
				-1.0, -1.0
			]
		}
	}

	bufferInfo = twgl.createBufferInfoFromArrays(gl, arrays)

	x = 0
	y = 0
	down = false
	$('#home').mousedown ->
		down = true;

	$('#home').mouseup ->
		down = false;

	$('#home').mousemove (event)->
		if down
			offset = $(this).offset()
			x = event.pageX - offset.left
			y = event.pageY - offset.top

	today = new Date()
	year = today.getFullYear()
	month = today.getMonth()
	day = today.getDay()

	render = (time)->
		twgl.resizeCanvasToDisplaySize(gl.canvas);
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height)

		uniforms =
			iResolution: [gl.canvas.width, gl.canvas.height, 0]
			iGlobalTime: time / 1000
			iChannelTime: [0, 0, 0, 0]
			iChannelResolution: imagePassChannelResolution
			iMouse: [x, y, 0, 0]
			iDate: [year, month, day, time / 1000]
			iSampleRate: 441000

		for name in imagePassTextures
			uniforms[name] = imagePassTextures[name]

		gl.useProgram(programInfo.program)
		twgl.setBuffersAndAttributes(gl, programInfo, bufferInfo)
		twgl.setUniforms(programInfo, uniforms)
		twgl.drawBufferInfo(gl, gl.TRIANGLE_STRIP, bufferInfo)

		requestAnimationFrame(render)

	requestAnimationFrame(render)
