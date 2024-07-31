#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct Light
{
    float lightIntensity;
    int lightType;
    int lightCastShadow;
    int lightShadowMapIndex;
    int lightAngleAttenCurveType;
    int lightDistAttenCurveType;
    float2 lightSize;
    int4 lightGUID;
    float4 lightPosition;
    float4 lightColor;
    float4 lightDirection;
    float4 lightDistAttenCurveParams[2];
    float4 lightAngleAttenCurveParams[2];
    float4x4 lightVP;
    float4 padding[2];
};

struct PerFrameConstants
{
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4 camPos;
    int numLights;
    Light allLights[100];
};

struct PerBatchConstants
{
    float4x4 modelMatrix;
};

struct main0_out
{
    float4 outputColor [[color(0)]];
};

struct main0_in
{
    float3 UVW [[user(locn0)]];
};

static inline __attribute__((always_inline))
float3 exposure_tone_mapping(thread const float3& color)
{
    return float3(1.0) - exp((-color) * 1.0);
}

static inline __attribute__((always_inline))
float3 gamma_correction(thread const float3& color)
{
    return powr(color, float3(0.4545454680919647216796875));
}

fragment main0_out main0(main0_in in [[stage_in]], texturecube_array<float> skybox [[texture(0)]], sampler skyboxSmplr [[sampler(0)]])
{
    main0_out out = {};
    float4 _46 = float4(in.UVW, 0.0);
    out.outputColor = skybox.sample(skyboxSmplr, _46.xyz, uint(rint(_46.w)), level(0.0));
    float3 param = out.outputColor.xyz;
    float3 _51 = exposure_tone_mapping(param);
    out.outputColor.x = _51.x;
    out.outputColor.y = _51.y;
    out.outputColor.z = _51.z;
    float3 param_1 = out.outputColor.xyz;
    float3 _66 = gamma_correction(param_1);
    out.outputColor.x = _66.x;
    out.outputColor.y = _66.y;
    out.outputColor.z = _66.z;
    return out;
}

