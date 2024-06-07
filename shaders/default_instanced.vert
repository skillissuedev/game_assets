#version 330

const int MAX_JOINTS = 128;
const int MAX_INSTANCES = 4096;

in vec3 position;
in vec3 normal;
in vec2 tex_coords;
in vec4 joints;
in vec4 weights;
in mat4 model;
//in int gl_InstanceID;

uniform jointsMats {
    mat4 jointsMatsArr[MAX_JOINTS];
};

uniform jointsInverseBindMats {
    mat4 jointsInverseBindMatsArr[MAX_JOINTS]; 
};

uniform mat4 view;
uniform mat4 proj;

out vec2 v_tex_coords;
out vec3 v_normal;
out vec3 v_frag_pos;

void main() {
    vec3 pos = vec3(-position.x, position.y, -position.z);
    if (joints.x == 0 && joints.y == 0 && joints.z == 0 && joints.w == 0) {
        gl_Position = proj * view * model * vec4(pos, 1.0);
    } else {
        mat4 skinMat =
	    weights.x * jointsMatsArr[int(joints.x)] * jointsInverseBindMatsArr[int(joints.x)] +
            weights.y * jointsMatsArr[int(joints.y)] * jointsInverseBindMatsArr[int(joints.y)] +
            weights.z * jointsMatsArr[int(joints.z)] * jointsInverseBindMatsArr[int(joints.z)] +
            weights.w * jointsMatsArr[int(joints.w)] * jointsInverseBindMatsArr[int(joints.w)];

        gl_Position = proj * view * model * skinMat * vec4(pos, 1.0);
    }

    v_tex_coords = tex_coords;
    v_normal = normal;
    v_frag_pos = vec3(model * vec4(pos, 1.0));
}
