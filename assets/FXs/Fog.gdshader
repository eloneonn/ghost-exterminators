shader_type canvas_item;

render_mode blend_sub;

uniform float transp :hint_range(0.0, 1.0, 0.1);

uniform float speed : hint_range(0.0, 0.5, 0.001);
uniform float pixel_count : hint_range(1.0, 512.0, 1.0);

uniform sampler2D noise1;
uniform sampler2D noise2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	float pixel_size = 1.0 / pixel_count;
    vec2 pixel_uv = floor(UV / pixel_size) * pixel_size;
	
	vec2 uv1 = pixel_uv;
	vec2 uv2 = pixel_uv;
	
	uv1.x = fract(uv1.x + cos(TIME * speed));
	uv1.y = fract(uv1.y - TIME * speed * 0.1);
	
	uv2.x = fract(uv2.x - cos(TIME * speed * 1.2));
	uv2.y = fract(uv2.y - TIME * speed * 0.25);
	
	vec4 fog = texture(noise1, uv1) * texture(noise2, uv2);
	
	//COLOR = texture(noise1, uv1);
	COLOR = vec4(fog.rgb, fog.r) * transp;
}
