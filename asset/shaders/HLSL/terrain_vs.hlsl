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

cbuffer PerBatchConstants : register(b1, space0)
{
    row_major float4x4 _50_modelMatrix : packoffset(c0);
};

Texture2D<float4> terrainHeightMap : register(t11, space0);
SamplerState _terrainHeightMap_sampler : register(s11, space0);

static float4 gl_Position;
static float3 inputPosition;

struct SPIRV_Cross_Input
{
    float3 inputPosition : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 gl_Position : SV_Position;
};

void vert_main()
{
    float height = terrainHeightMap.SampleLevel(_terrainHeightMap_sampler, inputPosition.xy / 10800.0f.xx, 0.0f).x * 10.0f;
    float4 displaced = float4(inputPosition.xy, height, 1.0f);
    gl_Position = mul(displaced, _50_modelMatrix);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    inputPosition = stage_input.inputPosition;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    return stage_output;
}
