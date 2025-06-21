shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec4 texture_src = texture(TEXTURE, UV);
	COLOR = vec4(0, 0, 0, texture_src.a);
}
