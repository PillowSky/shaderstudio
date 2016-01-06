'use strict'

class SoundRender extends ShaderRender
	initialize: =>
		super()

	render: (time)=>
		console.log(time)

	start: =>
		@fbo = twgl.createFramebufferInfo(@gl, [
			{ format: @gl.RGBA, type: @gl.UNSIGNED_BYTE, min: @gl.LINEAR, wrap: @gl.CLAMP_TO_EDGE, width: 1024, height: 1024},
		], 1024, 1024)
		twgl.bindFramebufferInfo(@gl, @fbo)

		@gl.viewport(0, 0, @gl.canvas.width, @gl.canvas.height)

		# update uniforms
		d = new Date()
		uniforms =
			iResolution: [@gl.canvas.width, @gl.canvas.height, 0]
			iGlobalTime:  0
			iChannelTime: @channelTimes
			iChannelResolution: @channelResolutions
			iDate: [d.getFullYear(), d.getMonth(), d.getDate(), d.getHours()*3600 + d.getMinutes()*60 + d.getSeconds() + d.getMilliseconds()/1000]

		twgl.setUniforms(@programInfo, uniforms)

		context = new AudioContext()
		sampleRate = 44100
		playTime = 60
		playSamples = playTime * sampleRate
		textureDimension = 1024
		tempBufferSamples = textureDimension * textureDimension
		buffer = context.createBuffer(2, playSamples, sampleRate)
		numSamples = tempBufferSamples

		bufL = buffer.getChannelData(0)
		bufR = buffer.getChannelData(1)
		data = new Uint8Array(tempBufferSamples * 4)

		numBlocks = playSamples / numSamples
		console.log(numBlocks)
		@gl.useProgram(@programInfo.program)
		twgl.setBuffersAndAttributes(@gl, @programInfo, @bufferInfo)
		for j in [0...numBlocks]
			offset = j * tempBufferSamples
			twgl.setUniforms(@programInfo, {'iBlockOffset': offset / sampleRate})
			twgl.drawBufferInfo(@gl, @gl.TRIANGLE_STRIP, @bufferInfo)
			@gl.readPixels(0, 0, textureDimension, textureDimension, @gl.RGBA, @gl.UNSIGNED_BYTE, data)

			for i in [0...numSamples]
				bufL[offset+i] = -1.0 + 2.0*(data[4*i+0]+256.0*data[4*i+1])/65535.0
				bufR[offset+i] = -1.0 + 2.0*(data[4*i+2]+256.0*data[4*i+3])/65535.0

		playnode = context.createBufferSource()
		playnode.connect(context.destination)
		playnode.start()
		playnode.buffer = buffer

	start: =>
		if not @isStarted
			@isStarted = true
			@gl.useProgram(@programInfo.program)
			twgl.setBuffersAndAttributes(@gl, @programInfo, @bufferInfo)
			@render()

window.SoundRender = SoundRender
