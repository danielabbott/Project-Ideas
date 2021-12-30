#version 330 core

// This is a proof of concept. It is not optimised and only supports straight edges which are defined in a constant array





uniform vec2 window_dimensions;


// In pixels. Top left is 0,0
in vec2 pass_position;


// square
// #define COORDS_COUNT 5
// vec2 coords[COORDS_COUNT] = vec2[](
//     vec2(100, 100),
//     vec2(200, 100),
//     vec2(200, 200),
//     vec2(100, 200),
//     vec2(100, 100)
// );

// Diamond
// #define COORDS_COUNT 5
// vec2 coords[COORDS_COUNT] = vec2[](
//     vec2(400, 100),
//     vec2(600, 300),
//     vec2(400, 500),
//     vec2(200, 300),
//     vec2(400, 100)
// );

// Duck https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/duck.svg
#define COORDS_COUNT 45
vec2 coords[COORDS_COUNT] = vec2[](
    vec2(0, 112)*2+100,
    vec2(20, 124)*2+100,
	vec2(40, 129)*2+100,
	vec2(60, 126)*2+100,
	vec2(80, 120)*2+100,
	vec2(100, 111)*2+100,
	vec2(120, 104)*2+100,
	vec2(140, 101)*2+100,
	vec2(164, 106)*2+100,
	vec2(170, 103)*2+100,
	vec2(173, 80)*2+100,
	vec2(178, 60)*2+100,
	vec2(185, 39)*2+100,
	vec2(200, 30)*2+100,
	vec2(220, 30)*2+100,
	vec2(240, 40)*2+100,
	vec2(260, 61)*2+100,
	vec2(280, 69)*2+100,
	vec2(290, 68)*2+100,
	vec2(288, 77)*2+100,
	vec2(272, 85)*2+100,
	vec2(250, 85)*2+100,
	vec2(230, 85)*2+100,
	vec2(215, 88)*2+100,
	vec2(211, 95)*2+100,
	vec2(215, 110)*2+100,
	vec2(228, 120)*2+100,
	vec2(241, 130)*2+100,
	vec2(251, 149)*2+100,
	vec2(252, 164)*2+100,
	vec2(242, 181)*2+100,
	vec2(221, 189)*2+100,
	vec2(200, 191)*2+100,
	vec2(180, 193)*2+100,
	vec2(160, 192)*2+100,
	vec2(140, 190)*2+100,
	vec2(120, 190)*2+100,
	vec2(100, 188)*2+100,
	vec2(80, 182)*2+100,
	vec2(61, 179)*2+100,
	vec2(42, 171)*2+100,
	vec2(30, 159)*2+100,
	vec2(13, 140)*2+100,
	vec2(00, 112)*2+100,
    vec2(0, 112)*2+100
);


void main()
{
	gl_FragColor = vec4(0,0,0,1);

	int rhs_intersections_count = 0;
	int intersections_count = 0;
	float aa_alpha = 1;

	for(int i = 0; i < COORDS_COUNT-1; i++) {
		vec2 p0 = coords[i];
		vec2 p1 = coords[i+1];

		vec2 line_delta = p1-p0;
		float len = length(line_delta);

		if(p0.y == p1.y) {
			if(p0.y == pass_position.y) {
				gl_FragColor = vec4(0,0,1,1);
				return;
			}
			continue;
		}	

		vec2 intersection;

		if(p0.x == p1.x) {
			intersection = vec2(p0.x, pass_position.y);
		}
		else {
			// gradient.
			float m = (p1.y - p0.y) / (p1.x - p0.x);

			// y = mx+c
			// c = y - mx

			// y-intercept
			float c = p0.y - m * p0.x;

			// y = mx+c
			// x = (y - c) / m

			intersection = vec2((pass_position.y - c) / m, pass_position.y);
		}

		vec2 intersect_line_delta = intersection - p0;


		if(sign(intersect_line_delta.y) == sign(line_delta.y) && 
			length(intersection - p0) <= len) 
		{
			// Intersection

			intersections_count++;
			if(intersection.x > pass_position.x) {
				rhs_intersections_count++;
			}

			if(abs(intersection.x - pass_position.x) <= 1.5) {
				aa_alpha = 0.5;
			}
		}


	}

	if(intersections_count > 0 && rhs_intersections_count % 2 != 0) {
		gl_FragColor = vec4(0, 0, 1*aa_alpha, 1);

		// Uncomment to highlight edges
		// if(aa_alpha > 0.9) {
		// 	gl_FragColor = vec4(0, 0, 1, 1);
		// }
		// else {
		// 	gl_FragColor = vec4(0, 1, 0, 1);
		// }
	}

}
