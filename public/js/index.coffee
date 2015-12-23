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

	gl = twgl.getWebGLContext(document.querySelector('canvas.home'))
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

	render = (time)->
		twgl.resizeCanvasToDisplaySize(gl.canvas);
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height)

		uniforms =
			iResolution: [gl.canvas.width, gl.canvas.height, 0]
			iGlobalTime: time / 1000

		gl.useProgram(programInfo.program)
		twgl.setBuffersAndAttributes(gl, programInfo, bufferInfo)
		twgl.setUniforms(programInfo, uniforms)
		twgl.drawBufferInfo(gl, gl.TRIANGLE_STRIP, bufferInfo)

		requestAnimationFrame(render)

	requestAnimationFrame(render)
