'use strict'

$ ->
	gl = twgl.getWebGLContext(document.getElementById('canvas'))

	programInfo = twgl.createProgramInfo(gl, ['vs', 'fs'])

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

	textureConfig = {}
	iChannelResolution = new Float32Array(12)

	window.inputs.forEach (input)->
		if input.ctype == 'texture'
			texture =
				'src': input.src

			switch input.sampler.filter
				when 'nearest'
					texture.filter = gl.NEAREST
				when 'linear'
					texture.filter = gl.LINEAR
				when 'mipmap'
					texture.filter = gl.LINEAR_MIPMAP_LINEAR

			switch input.sampler.wrap
				when 'clamp'
					texture.wrap = gl.CLAMP_TO_EDGE
				when 'repeat'
					texture.wrap = gl.REPEAT

			switch input.sampler.vflip
				when 'true'
					texture.flipY = true
				when 'false'
					texture.flipY = false

			textureConfig['ichannel' + input.channel] = texture

			iChannelResolution[input.channel * 3] = input.info.width
			iChannelResolution[input.channel * 3 + 1] = input.info.height

	textures = twgl.createTextures(gl, textureConfig)

	x = 0
	y = 0
	down = false
	$('#canvas').mousedown ->
		down = true;

	$('#canvas').mouseup ->
		down = false;

	$('#canvas').mousemove (event)->
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

		today = new Date()
		uniforms =
			iResolution: [gl.canvas.width, gl.canvas.height, 0]
			iGlobalTime: time / 1000
			iChannelTime: [0, 0, 0, 0]
			iChannelResolution: iChannelResolution
			iMouse: [x, y, 0, 0]
			iDate: [year, month, day, time / 1000]
			iSampleRate: 441000

		for name in textureConfig
			uniforms[name] = textures[name]

		gl.useProgram(programInfo.program)
		twgl.setBuffersAndAttributes(gl, programInfo, bufferInfo)
		twgl.setUniforms(programInfo, uniforms)
		twgl.drawBufferInfo(gl, gl.TRIANGLE_STRIP, bufferInfo)

		requestAnimationFrame(render)

	requestAnimationFrame(render)
