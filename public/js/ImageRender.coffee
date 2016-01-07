'use strict'

class ImageRender extends ShaderRender
	initialize: =>
		super()
		@mouse.mousedown =>
			base = @mouse.offset()
			@mousePositions[2] = event.pageX - base.left
			@mousePositions[3] = event.pageY - base.top

			@mouse.mousemove (event)=>
				offset = @mouse.offset()
				@mousePositions[0] = event.pageX - offset.left
				@mousePositions[1] = event.pageY - offset.top

		@mouse.mouseup =>
			@mouse.unbind('mousemove')

	render: (time)=>
		twgl.resizeCanvasToDisplaySize(@gl.canvas);
		@gl.viewport(0, 0, @gl.canvas.width, @gl.canvas.height)

		# update inputs
		for texConfig in @textureConfigs
			texConfig?.update?()

		# update uniforms
		d = new Date()
		uniforms =
			iResolution: [@gl.canvas.width, @gl.canvas.height, 0]
			iGlobalTime: (time - @timestamp) / 1000
			iChannelTime: @channelTimes
			iChannelResolution: @channelResolutions
			iMouse: @mousePositions
			iDate: [d.getFullYear(), d.getMonth(), d.getDate(), d.getHours()*3600 + d.getMinutes()*60 + d.getSeconds() + d.getMilliseconds()/1000]
			iSampleRate: 44100

		# update texture
		for channel, texture of @textures
			uniforms['iChannel' + channel] = texture

		twgl.setUniforms(@programInfo, uniforms)
		twgl.drawBufferInfo(@gl, @gl.TRIANGLE_STRIP, @bufferInfo)

		requestAnimationFrame(@render) if @isStarted

	start: =>
		if not @isStarted
			@timestamp = performance.now() - @laststamp
			if @everStarted
				for texConfig in @textureConfigs
					texConfig?.audio?.resume?()
					texConfig?.video?.play?()
			@isStarted = @everStarted = true
			@render(performance.now())

	stop: =>
		if @isStarted
			@laststamp = performance.now() - @timestamp
			for texConfig in @textureConfigs
				texConfig?.audio?.suspend?()
				texConfig?.video?.pause?()
			@isStarted = false

window.ImageRender = ImageRender
