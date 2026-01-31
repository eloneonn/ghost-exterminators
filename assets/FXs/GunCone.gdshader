shader_type canvas_item;

uniform float fxTransparency : hint_range(0.0, 1.0, 0.1);

uniform vec4 coneColor : source_color;

uniform float speed1 : hint_range(0.0, 4.0, 0.1);
uniform float speed2 : hint_range(0.0, 4.0, 0.1);

uniform sampler2D noise1;
uniform sampler2D noise2;

uniform sampler2D gradientMask;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Used as mask for the final effect
	float coneAlpha = texture(TEXTURE, UV).a;
	
	vec2 uv1 = UV;
	vec2 uv2 = UV;
	
	uv1.y = fract(uv1.y + TIME * speed1);
	uv2.y = fract(uv2.y + TIME * speed2);
	
	vec4 waveTexture = texture(noise1, uv1) * texture(noise2, uv2);
	vec4 finalColor = coneColor + vec4(waveTexture.rgb, waveTexture.r);
	
	float gradient = texture(gradientMask, UV).r;
	
	COLOR = finalColor  * coneAlpha * gradient * fxTransparency;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
