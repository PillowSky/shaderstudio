#extension GL_OES_standard_derivatives : enable
#extension GL_EXT_shader_texture_lod : enable

precision mediump float;

uniform vec3 iResolution;
uniform float iGlobalTime;
uniform float iChannelTime[4];
uniform vec3 iChannelResolution[4];
uniform vec4 iMouse;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform vec4 iDate;
uniform float iSampleRate;
uniform float iFrameDimension;

vec2 mainSound(float time);

void main() {
	float t = iGlobalTime + (gl_FragCoord.x + gl_FragCoord.y * iFrameDimension) / iSampleRate;
	vec2 y = mainSound(t);
	vec2 v = floor((0.5 + 0.5*y) * 65536.0);
	vec2 vl = mod(v, 256.0) / 255.0;
	vec2 vh = floor(v / 256.0) / 255.0;
	gl_FragColor = vec4(vl.x, vh.x, vl.y, vh.y);
}
