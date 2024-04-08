#version 330

uniform sampler2D tex;
uniform vec3 lightPos;  
uniform sampler2D closestShadowTexture;
uniform sampler2D furthestShadowTexture;

in vec2 v_tex_coords;
in vec3 v_frag_pos;
in vec3 v_normal;
in vec4 v_closest_light_frag_pos;
in vec4 v_furthest_light_frag_pos;

out vec4 color;

float ShadowCalculation(vec4 fragPosLightSpace)
{
    // perform perspective divide
    vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
    // transform to [0,1] range
    projCoords = projCoords * 0.5 + 0.5;
    // get closest depth value from light's perspective (using [0,1] range fragPosLight as coords)
    float closestDepth = texture(closestShadowTexture, projCoords.xy).r; 
    // get depth of current fragment from light's perspective
    float currentDepth = projCoords.z;
    // check whether current frag pos is in shadow
    float shadow = currentDepth > closestDepth  ? 1.0 : 0.0;

    float bias = 0.005;
    vec2 texelSize = 1.0 / textureSize(closestShadowTexture, 0);
    for(int x = -2; x <= 2; ++x)
    {
        for(int y = -2; y <= 2; ++y)
        {
            float pcfDepth = texture(closestShadowTexture, v_closest_light_frag_pos.xy + vec2(x, y) * texelSize).r; 
            shadow += currentDepth - bias > pcfDepth ? 1.0 : 0.0;        
        }    
    }
    shadow /= 9.0;

    return shadow;
}  

void main() {
    vec3 lightColor = vec3(1.0, 1.0, 1.0);
    float ambient = 0.1;
    vec3 ambientColor = ambient * lightColor;

    vec3 norm = normalize(v_normal);
    vec3 lightDir = normalize(lightPos - v_frag_pos);
    
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    vec4 object_color = texture(tex, v_tex_coords);

    //vec3 cel_shaded = floor((diffuse) * 4) / 4;


    //shadow mapping
    float shadow = ShadowCalculation(v_closest_light_frag_pos);

    float bias = 0.005;
    float visibility = 1.0;
    if (texture(closestShadowTexture, v_closest_light_frag_pos.xy).z < v_closest_light_frag_pos.z - bias){
        visibility = 0.5;
    }

    vec3 lighting = visibility * (ambientColor + (1.0 - shadow) * diffuse) * vec3(object_color);
    color = vec4(lighting, 1.0);
}
