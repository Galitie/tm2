shader_type canvas_item;

uniform vec2 parent_part_world_pos;
uniform vec4 parent_part_color;

uniform vec4 part_color;

varying vec2 vertex_world;
varying vec2 parent_part_vertex_space;

void vertex() {
	vertex_world = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	parent_part_vertex_space = (inverse(MODEL_MATRIX) * vec4(parent_part_world_pos, 0.0, 1.0)).xy;
}

void fragment() {
	float dist = distance(vertex_world, parent_part_world_pos);
	float influence = 140.0;
	if (dist > influence) {
		dist = influence;
	}
	float norm = dist / influence;
	
	/*if (dist < 40.0) {
		COLOR = vec4(1.0, 0.0, 0.0, COLOR.a);
	}
	else {
		COLOR = vec4(0.0, 1.0, 0.0, COLOR.a);
	}*/
	if (parent_part_color.a == 0.0) {
		COLOR = vec4(part_color.xyz, COLOR.a);
	}
	else {
		COLOR = vec4(mix(parent_part_color.xyz, part_color.xyz, norm).xyz, COLOR.a);
	}
	//COLOR = vec4(parent_part_color.xyz, COLOR.a);
}
