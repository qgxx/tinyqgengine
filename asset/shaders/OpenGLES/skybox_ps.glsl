#version 310 es
precision mediump float;
precision highp int;

struct Light
{
    highp float lightIntensity;
    int lightType;
    int lightCastShadow;
    int lightShadowMapIndex;
    int lightAngleAttenCurveType;
    int lightDistAttenCurveType;
    highp vec2 lightSize;
    ivec4 lightGUID;
    highp vec4 lightPosition;
    highp vec4 lightColor;
    highp vec4 lightDirection;
    highp vec4 lightDistAttenCurveParams[2];
    highp vec4 lightAngleAttenCurveParams[2];
    highp mat4 lightVP;
    highp vec4 padding[2];
};

layout(binding = 4) uniform highp samplerCubeArray skybox;

layout(location = 0) out highp vec4 outputColor;
layout(location = 0) in highp vec3 UVW;

highp vec3 exposure_tone_mapping(highp vec3 color)
{
    return vec3(1.0) - exp((-color) * 1.0);
}

highp vec3 gamma_correction(highp vec3 color)
{
    return pow(color, vec3(0.4545454680919647216796875));
}

void main()
{
    outputColor = textureLod(skybox, vec4(UVW, 0.0), 0.0);
    highp vec3 param = outputColor.xyz;
    highp vec3 _51 = exposure_tone_mapping(param);
    outputColor.x = _51.x;
    outputColor.y = _51.y;
    outputColor.z = _51.z;
    highp vec3 param_1 = outputColor.xyz;
    highp vec3 _66 = gamma_correction(param_1);
    outputColor.x = _66.x;
    outputColor.y = _66.y;
    outputColor.z = _66.z;
}

