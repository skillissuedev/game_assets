#version 330

const int MAX_JOINTS = 50;

in vec3 position;
in vec2 tex_coords;
in vec4 joints;
in vec4 weights;

uniform mat4 mvp;
uniform mat4 jointsMats[MAX_JOINTS];

out vec2 v_tex_coords;

void main() {
    mat4 skinMat =
        weights.x * jointMats[int(joints.x)] +
        weight.y * jointMats[int(joints.y)] +
        weight.z * jointMats[int(joints.z)] +
        weight.w * jointMats[int(joints.w)];

    gl_Position = mvp * skinMat * vec4(position, 1.0);
    v_tex_coords = tex_coords;
}
