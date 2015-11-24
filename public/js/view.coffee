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

	render = (time)->
		twgl.resizeCanvasToDisplaySize(gl.canvas);
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height)

		uniforms =
			iResolution: [gl.canvas.width, gl.canvas.height, 0]
			iGlobalTime: time / 1000
			iMouse: [x, y, 0, 0]

		gl.useProgram(programInfo.program);
		twgl.setBuffersAndAttributes(gl, programInfo, bufferInfo)
		twgl.setUniforms(programInfo, uniforms)
		twgl.drawBufferInfo(gl, gl.TRIANGLE_STRIP, bufferInfo)

		requestAnimationFrame(render)

	requestAnimationFrame(render);
