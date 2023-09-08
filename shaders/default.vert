#version 330

in vec3 position;
in vec2 tex_coords;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec2 v_tex_coords;

void main() {
    gl_Position = projection * view * model * vec4(position, 1.0);
    v_tex_coords = tex_coords;
}
