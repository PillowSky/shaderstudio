'use strict'

class SoundRender extends ShaderRender
	initialize: =>
		#prepare info
		@programInfo = twgl.createProgramInfo(@gl, [@vert, @frag + @pass.code])
		@bufferInfo = twgl.createBufferInfoFromArrays(@gl, {
			position: {
				numComponents: 2,
				data: new Float32Array([
					1.0, 1.0,
					-1.0, 1.0,
					1.0, -1.0,
					-1.0, -1.0
				])
			}
		})

		@fbo = twgl.createFramebufferInfo(@gl, [
			{ format: @gl.RGBA, type: @gl.UNSIGNED_BYTE, min: @gl.LINEAR, wrap: @gl.CLAMP_TO_EDGE, width: 512, height: 512},
		], 512, 512)
		twgl.bindFramebufferInfo(@gl, @fbo)

		twgl.resizeCanvasToDisplaySize(@gl.canvas);
		@gl.viewport(0, 0, @gl.canvas.width, @gl.canvas.height)

		# update uniforms
		d = new Date()
		uniforms =
			iResolution: [@gl.canvas.width, @gl.canvas.height, 0]
			iGlobalTime:  0
			iChannelTime: @channelTimes
			iChannelResolution: @channelResolutions
			iMouse: @mousePositions
			iDate: [d.getFullYear(), d.getMonth(), d.getDate(), d.getHours()*3600 + d.getMinutes()*60 + d.getSeconds() + d.getMilliseconds()/1000]

		twgl.setUniforms(@programInfo, uniforms)

		context = new AudioContext()
		sampleRate = 44100
		playTime = 60
		playSamples = playTime * sampleRate
		textureDimension = 512
		tempBufferSamples = textureDimension * textureDimension
		buffer = context.createBuffer(2, playSamples, sampleRate)
		numSamples = tempBufferSamples

		bufL = buffer.getChannelData(0)
		bufR = buffer.getChannelData(1)
		data = new Uint8Array(tempBufferSamples * 4)

		numBlocks = playSamples / numSamples

		@gl.useProgram(@programInfo.program)
		twgl.setBuffersAndAttributes(@gl, @programInfo, @bufferInfo)
		for j in [0...numBlocks]
			offset = j * tempBufferSamples
			twgl.setUniforms(@programInfo, {'iBlockOffset': offset / sampleRate})
			twgl.drawBufferInfo(@gl, @gl.TRIANGLE_STRIP, @bufferInfo)
			@gl.readPixels(0, 0, textureDimension, textureDimension, @gl.RGBA, @gl.UNSIGNED_BYTE, data)

			console.log(data)
			for i in [0...numSamples]
				bufL[offset+i] = -1.0 + 2.0*(data[4*i+0]+256.0*data[4*i+1])/65535.0
				bufR[offset+i] = -1.0 + 2.0*(data[4*i+2]+256.0*data[4*i+3])/65535.0

		playnode = context.createBufferSource()
		playnode.connect(context.destination)
		playnode.start()
		playnode.buffer = buffer

	render: (time)=>
		console.log(time)


window.SoundRender = SoundRender
