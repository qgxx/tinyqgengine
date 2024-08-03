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

static float4 outputColor;
static float4 normal_world;
static float4 v_world;
static float2 uv;
static float3x3 TBN;
static float3 v_tangent;
static float3 camPos_tangent;

struct SPIRV_Cross_Input
{
    float4 normal_world : TEXCOORD1;
    float4 v_world : TEXCOORD3;
    float2 uv : TEXCOORD4;
    float3x3 TBN : TEXCOORD5;
    float3 v_tangent : TEXCOORD8;
    float3 camPos_tangent : TEXCOORD9;
};

struct SPIRV_Cross_Output
{
    float4 outputColor : SV_Target0;
};

void frag_main()
{
    outputColor = 1.0f.xxxx;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    normal_world = stage_input.normal_world;
    v_world = stage_input.v_world;
    uv = stage_input.uv;
    TBN = stage_input.TBN;
    v_tangent = stage_input.v_tangent;
    camPos_tangent = stage_input.camPos_tangent;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.outputColor = outputColor;
    return stage_output;
}
