#version 330 core

vec2 positions[3] = vec2[](
    vec2(-1.0, 3.0),
    vec2(3.0, -1.0),
    vec2(-1.0, -1.0)
);

uniform vec2 windowDimensions;

out vec2 pass_position;

void main()
{
	vec2 in_position = positions[gl_VertexID];
	gl_Position = vec4(in_position, 0.0, 1.0);
	pass_position = (in_position + 1.0) * 0.5;
	pass_position.y = 1.0 - pass_position.y;
	pass_position *= windowDimensions;
}
