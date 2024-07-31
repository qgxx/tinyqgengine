////////////////////////////////////////////////////////////////////////////////
// Filename: basic_ps.glsl
////////////////////////////////////////////////////////////////////////////////

/////////////////////
// INPUT VARIABLES //
/////////////////////
layout(location = 0) in vec4 normal;
layout(location = 1) in vec4 normal_world;
layout(location = 2) in vec4 v; 
layout(location = 3) in vec4 v_world;
layout(location = 4) in vec2 uv;

//////////////////////
// OUTPUT VARIABLES //
//////////////////////
layout(location = 0) out vec4 outputColor;

//////////////////////
// CONSTANTS        //
//////////////////////
layout(push_constant) uniform constants_t {
    vec4 ambientColor;
    vec4 specularColor;
    float specularPower;
} u_pushConstants;

////////////////////////////////////////////////////////////////////////////////
// Pixel Shader
////////////////////////////////////////////////////////////////////////////////

vec3 apply_light(const Light light) {
    vec3 N = normalize(normal.xyz);
    vec3 L;
    vec3 light_dir = normalize((viewMatrix * light.lightDirection).xyz);

    if (light.lightPosition.w == 0.0f)
    {
        L = -light_dir;
    }
    else
    {
        L = (viewMatrix * light.lightPosition).xyz - v.xyz;
    }

    float lightToSurfDist = length(L);

    L = normalize(L);

    float cosTheta = clamp(dot(N, L), 0.0f, 1.0f);

    // shadow test
    float visibility = shadow_test(v_world, light, cosTheta);

    float lightToSurfAngle = acos(dot(L, -light_dir));

    // angle attenuation
    float atten = apply_atten_curve(lightToSurfAngle, light.lightAngleAttenCurveType, light.lightAngleAttenCurveParams);

    // distance attenuation
    atten *= apply_atten_curve(lightToSurfDist, light.lightDistAttenCurveType, light.lightDistAttenCurveParams);

    vec3 R = normalize(2.0f * dot(L, N) *  N - L);
    vec3 V = normalize(-v.xyz);

    vec3 linearColor;

    vec3 admit_light = light.lightIntensity * atten * light.lightColor.rgb;
    linearColor = texture(diffuseMap, uv).rgb * cosTheta; 
    if (visibility > 0.2f)
        linearColor += u_pushConstants.specularColor.rgb * pow(clamp(dot(R, V), 0.0f, 1.0f), u_pushConstants.specularPower); 
    linearColor *= admit_light;

    return linearColor * visibility;
}

vec3 apply_areaLight(const Light light)
{
    vec3 N = normalize(normal.xyz);
    vec3 right = normalize((viewMatrix * vec4(1.0f, 0.0f, 0.0f, 0.0f)).xyz);
    vec3 pnormal = normalize((viewMatrix * light.lightDirection).xyz);
    vec3 ppos = (viewMatrix * light.lightPosition).xyz;
    vec3 up = normalize(cross(pnormal, right));
    right = normalize(cross(up, pnormal));

    //width and height of the area light:
    float width = light.lightSize.x;
    float height = light.lightSize.y;

    //project onto plane and calculate direction from center to the projection.
    vec3 projection = projectOnPlane(v.xyz, ppos, pnormal);// projection in plane
    vec3 dir = projection - ppos;

    //calculate distance from area:
    vec2 diagonal = vec2(dot(dir,right), dot(dir,up));
    vec2 nearest2D = vec2(clamp(diagonal.x, -width, width), clamp(diagonal.y, -height, height));
    vec3 nearestPointInside = ppos + right * nearest2D.x + up * nearest2D.y;

    vec3 L = nearestPointInside - v.xyz;

    float lightToSurfDist = length(L);
    L = normalize(L);

    // distance attenuation
    float atten = apply_atten_curve(lightToSurfDist, light.lightDistAttenCurveType, light.lightDistAttenCurveParams);

    vec3 linearColor = vec3(0.0f);

    float pnDotL = dot(pnormal, -L);
    float nDotL = dot(N, L);

    if (nDotL > 0.0f && isAbovePlane(v.xyz, ppos, pnormal)) //looking at the plane
    {
        //shoot a ray to calculate specular:
        vec3 V = normalize(-v.xyz);
        vec3 R = normalize(2.0f * dot(V, N) *  N - V);
        vec3 R2 = normalize(2.0f * dot(L, N) *  N - L);
        vec3 E = linePlaneIntersect(v.xyz, R, ppos, pnormal);

        float specAngle = clamp(dot(-R, pnormal), 0.0f, 1.0f);
        vec3 dirSpec = E - ppos;
        vec2 dirSpec2D = vec2(dot(dirSpec, right), dot(dirSpec, up));
        vec2 nearestSpec2D = vec2(clamp(dirSpec2D.x, -width, width), clamp(dirSpec2D.y, -height, height));
        float specFactor = 1.0f - clamp(length(nearestSpec2D - dirSpec2D), 0.0f, 1.0f);

        vec3 admit_light = light.lightIntensity * atten * light.lightColor.rgb;

        linearColor = texture(diffuseMap, uv).rgb * nDotL * pnDotL; 
        linearColor += u_pushConstants.specularColor.rgb * pow(clamp(dot(R2, V), 0.0f, 1.0f), u_pushConstants.specularPower) * specFactor * specAngle; 
        linearColor *= admit_light;
    }

    return linearColor;
}

void main(void)
{
    vec3 linearColor = vec3(0.0f);
    for (int i = 0; i < numLights; i++)
    {
        if (allLights[i].lightType == 3) // area light
        {
            linearColor += apply_areaLight(allLights[i]); 
        }
        else
        {
            linearColor += apply_light(allLights[i]); 
        }
    }

    // add ambient color
    // linearColor += ambientColor.rgb;
    linearColor += textureLod(skybox, vec4(normal_world.xyz, 0), 8).rgb * vec3(0.20f);

    // tone mapping
    //linearColor = reinhard_tone_mapping(linearColor);
    linearColor = exposure_tone_mapping(linearColor);

    // gamma correction
    outputColor = vec4(gamma_correction(linearColor), 1.0f);
}