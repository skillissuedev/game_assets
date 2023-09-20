#version 330

const int MAX_JOINTS = 128;

in vec3 position;
in vec2 tex_coords;
in vec4 joints;
in vec4 weights;

uniform mat4 mvp;

uniform jointsMats {
    mat4 jointsMatsArr[MAX_JOINTS];
};

uniform jointsInverseBindMats {
    mat4 jointsInverseBindMatsArr[MAX_JOINTS]; 
};

out vec2 v_tex_coords;

void main() {
    mat4 skinMat =
        weights.x * jointsMatsArr[int(joints.x)] * jointsInverseBindMatsArr[int(joints.x)] +
        weights.y * jointsMatsArr[int(joints.y)] * jointsInverseBindMatsArr[int(joints.y)] +
        weights.z * jointsMatsArr[int(joints.z)] * jointsInverseBindMatsArr[int(joints.z)] +
        weights.w * jointsMatsArr[int(joints.w)] * jointsInverseBindMatsArr[int(joints.w)];
    /*vec4 final_position = vec4(0.0, 0.0, 0.0, 1.0);
    for (int i = 0; i < 4; ++i) {
        mat4 boneTransform = jointsMatsArr[int(joints[i])];
        final_position += weights[i] * (boneTransform * vec4(position, 1.0));
    }*/

    gl_Position = mvp * skinMat * vec4(position, 1.0);
    //gl_Position = mvp * final_position;
    v_tex_coords = tex_coords;
}
