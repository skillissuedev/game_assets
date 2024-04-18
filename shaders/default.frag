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

float ClosestShadowCalculation(vec4 fragPosLightSpace)
{
    vec2 texelSize = 1.0 / textureSize(closestShadowTexture, 0);
    // perform perspective divide
    vec3 projCoords = v_closest_light_frag_pos.xyz / v_closest_light_frag_pos.w;
    // transform to [0,1] range
    projCoords = projCoords * 0.5 + 0.5;
    // get closest depth value from light's perspective (using [0,1] range fragPosLight as coords)
    float closestDepth = texture(closestShadowTexture, projCoords.xy).r; 
    // get depth of current fragment from light's perspective
    float currentDepth = projCoords.z;
    // check whether current frag pos is in shadow
    float shadow = 0;//currentDepth > closestDepth  ? 1.0 : 0.0;
    for(int x = -1; x <= 1; ++x)
    {
        for(int y = -1; y <= 1; ++y)
        {
            float bias = 0.001;
            float pcfDepth = texture(closestShadowTexture, projCoords.xy + vec2(x, y) * texelSize).r; 
            shadow += currentDepth - bias > pcfDepth ? 1.0 : 0.0;        
        }    
    }
    shadow /= 100.0;
    return shadow;
}
/*
{
    // perform perspective divide
    vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
    // transform to [0,1] range
    projCoords = projCoords * 0.5 + 0.5;
    // get closest depth value from light's perspective (using [0,1] range fragPosLight as coords)
    float closestDepth = texture(closestShadowTexture, projCoords.xy).r; 
    // get depth of current fragment from light's perspective
    float currentDepth = projCoords.z;

    float bias = 0.0008;
    // check whether current frag pos is in shadow
    float shadow = currentDepth > closestDepth + bias ? 1.0 : 0.0;
    

    return shadow;
}  
*/

float FurthestShadowCalculation(vec4 fragPosLightSpace) {
    vec2 texelSize = 1.0 / textureSize(furthestShadowTexture, 0);
    // perform perspective divide
    vec3 projCoords = v_furthest_light_frag_pos.xyz / v_furthest_light_frag_pos.w;
    // transform to [0,1] range
    projCoords = projCoords * 0.5 + 0.5;
    // get furthest depth value from light's perspective (using [0,1] range fragPosLight as coords)
    float furthestDepth = texture(furthestShadowTexture, projCoords.xy).r; 
    // get depth of current fragment from light's perspective
    float currentDepth = projCoords.z;
    // check whether current frag pos is in shadow
    float shadow = 0;//currentDepth > furthestDepth  ? 1.0 : 0.0;
    for(int x = -1; x <= 1; ++x)
    {
        for(int y = -1; y <= 1; ++y)
        {
            float bias = 0.001;
            float pcfDepth = texture(furthestShadowTexture, projCoords.xy + vec2(x, y) * texelSize).r; 
            shadow += currentDepth - bias > pcfDepth ? 1.0 : 0.0;        
        }    
    }
    shadow /= 100.0;
    return shadow;
}

void main() {
    vec3 lightColor = vec3(1.0, 1.0, 1.0);
    float ambient = 0.15;
    vec3 ambientColor = ambient * lightColor;

    vec3 norm = normalize(v_normal);
    vec3 lightDir = normalize(lightPos - v_frag_pos);
    
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    vec4 object_color = texture(tex, v_tex_coords);

    //vec3 cel_shaded = floor((diffuse) * 4) / 4;


    //shadow mapping
    float shadow;
    if (length(v_frag_pos - cameraPosition) > 50) { // cascade 2 
        shadow = FurthestShadowCalculation(v_furthest_light_frag_pos);
    } else {
        shadow = ClosestShadowCalculation(v_closest_light_frag_pos);
    }


    vec3 lighting = /*visibility * */((ambientColor - shadow) * diffuse/*cel_shaded*/) * vec3(object_color);
    color = vec4(lighting, 1.0);
}
