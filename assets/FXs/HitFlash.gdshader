shader_type canvas_item;
render_mode unshaded;

uniform vec4 flashColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool enable = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec4 spriteTexture = texture(TEXTURE, UV);
	vec3 finalColor = spriteTexture.rgb;
	
	if (enable){
		finalColor = vec3(flashColor.rgb);
	}
	
	COLOR = vec4(finalColor, spriteTexture.a);
}
