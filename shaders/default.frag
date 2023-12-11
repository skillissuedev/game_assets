#version 330

uniform sampler2D tex;
uniform vec3 lightPos;  

in vec2 v_tex_coords;
in vec3 v_frag_pos;
in vec3 v_normal;

out vec4 color;

void main() {
    vec3 lightColor = vec3(1.0, 1.0, 1.0);
    float ambient = 0.1;
    vec3 ambientColor = ambient * lightColor;

    vec3 norm = normalize(v_normal);
    vec3 lightDir = normalize(lightPos - v_frag_pos);
    
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    vec4 object_color = texture(tex, v_tex_coords);

    vec3 cel_shaded = floor((diffuse) * 4) / 4;
    color = vec4(ambientColor, 1.0) * vec4(cel_shaded, 1.0) * object_color;
}

