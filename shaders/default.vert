#version 330

in vec3 position;
in vec2 tex_coords;

uniform mat4 mvp;

out vec2 v_tex_coords;

void main() {
    gl_Position = mvp * vec4(position, 1.0);
    v_tex_coords = tex_coords;
}
