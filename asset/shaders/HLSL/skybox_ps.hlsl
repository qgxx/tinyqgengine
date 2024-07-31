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
    row_major float4x4 lightVP;
    float4 padding[2];
};

TextureCubeArray<float4> skybox : register(t4, space0);
SamplerState _skybox_sampler : register(s4, space0);

static float4 outputColor;
static float3 UVW;

struct SPIRV_Cross_Input
{
    float3 UVW : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 outputColor : SV_Target0;
};

float3 exposure_tone_mapping(float3 color)
{
    return 1.0f.xxx - exp((-color) * 1.0f);
}

float3 gamma_correction(float3 color)
{
    return pow(color, 0.4545454680919647216796875f.xxx);
}

void frag_main()
{
    outputColor = skybox.SampleLevel(_skybox_sampler, float4(UVW, 0.0f), 0.0f);
    float3 param = outputColor.xyz;
    float3 _51 = exposure_tone_mapping(param);
    outputColor.x = _51.x;
    outputColor.y = _51.y;
    outputColor.z = _51.z;
    float3 param_1 = outputColor.xyz;
    float3 _66 = gamma_correction(param_1);
    outputColor.x = _66.x;
    outputColor.y = _66.y;
    outputColor.z = _66.z;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    UVW = stage_input.UVW;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.outputColor = outputColor;
    return stage_output;
}
