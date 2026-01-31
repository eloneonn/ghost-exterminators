shader_type canvas_item;
render_mode light_only, blend_mix;

uniform sampler2D mask;

uniform float speed : hint_range(0.0, 1.0, 0.01);
uniform float amp : hint_range(0.0, 1.0, 0.01);

uniform float fps : hint_range(0.0, 12.0, 1.0);

varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	
	float steppedTime = floor(TIME * fps)/ fps;
	
	vec2 uv1 = UV;
	vec2 uv2 = UV;
	uv1 = vec2(uv1.x + cos(steppedTime * speed * amp), uv1.y - steppedTime * 0.02);
	uv2 = vec2(uv2.x - cos(steppedTime * speed * amp) + 0.5, uv2.y - steppedTime * 0.01);
	
	vec4 col1 = texture(TEXTURE, uv1);
	vec4 col2 = texture(TEXTURE, uv2);
	
	float maskAlpha = texture(mask, UV).r;
	
	COLOR = mix(col1, col2, maskAlpha) * modulate;
	//COLOR = texture(mask, UV);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
