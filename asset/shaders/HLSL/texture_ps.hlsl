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

Texture2D<float4> tex : register(t0, space0);
SamplerState _tex_sampler : register(s0, space0);

static float3 color;
static float2 UV;

struct SPIRV_Cross_Input
{
    float2 UV : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float3 color : SV_Target0;
};

void frag_main()
{
    color = tex.Sample(_tex_sampler, UV).xyz;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    UV = stage_input.UV;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.color = color;
    return stage_output;
}
