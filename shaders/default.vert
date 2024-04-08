#version 330

const int MAX_JOINTS = 128;

in vec3 position;
in vec3 normal;
in vec2 tex_coords;
in vec4 joints;
in vec4 weights;

uniform mat4 mvp;
uniform mat4 closestShadowViewProj;
uniform mat4 furthestShadowViewProj;
uniform mat4 model;

uniform jointsMats {
    mat4 jointsMatsArr[MAX_JOINTS];
};

uniform jointsInverseBindMats {
    mat4 jointsInverseBindMatsArr[MAX_JOINTS]; 
};

out vec2 v_tex_coords;
out vec3 v_normal;
out vec3 v_frag_pos;
out vec4 v_closest_light_frag_pos;
out vec4 v_furthest_light_frag_pos;

void main() {
     if (joints.x == 0 && joints.y == 0 && joints.z == 0 && joints.w == 0) {
        gl_Position = mvp * vec4(position, 1.0);
    } else {
        mat4 skinMat =
	    weights.x * jointsMatsArr[int(joints.x)] * jointsInverseBindMatsArr[int(joints.x)] +
            weights.y * jointsMatsArr[int(joints.y)] * jointsInverseBindMatsArr[int(joints.y)] +
            weights.z * jointsMatsArr[int(joints.z)] * jointsInverseBindMatsArr[int(joints.z)] +
            weights.w * jointsMatsArr[int(joints.w)] * jointsInverseBindMatsArr[int(joints.w)];

        gl_Position = mvp * skinMat * vec4(position, 1.0);
    }

    v_tex_coords = tex_coords;
    v_normal = normal;
    v_frag_pos = vec3(model * vec4(position, 1.0));
    v_closest_light_frag_pos = closestShadowViewProj * vec4(v_frag_pos, 1.0);
    v_furthest_light_frag_pos = furthestShadowViewProj * vec4(v_frag_pos, 1.0);
}
