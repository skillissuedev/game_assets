#version 330

uniform sampler2D tex;
uniform vec3 lightPos;  
uniform vec3 cameraPosition;  
uniform sampler2D closestShadowTexture;
uniform sampler2D furthestShadowTexture;
in vec2 v_tex_coords;
in vec3 v_frag_pos;
in vec3 v_normal;
in vec4 v_closest_light_frag_pos;
in vec4 v_furthest_light_frag_pos;
out vec4 color;

void main() {
    vec3 lightColor = vec3(0.8, 0.8, 0.9);
    float ambient = 0.20;
    vec3 ambientColor = ambient * lightColor;

    vec3 norm = normalize(v_normal);
    vec3 lightDir = normalize(lightPos - v_frag_pos);
    
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;
    float gamma = 1.2;
    diffuse = pow(diffuse, vec3(gamma));

    vec4 object_color = texture(tex, v_tex_coords);

    vec3 cel_shaded = floor((diffuse) * 3) / 3;

    vec3 final_color = vec3(object_color) * (diffuse + ambientColor);
    color = vec4(final_color, 1.0);
}
