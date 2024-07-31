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

static float4 gl_Position;
static float3 inputPosition;
static float3 UVW;
static float3 inputUVW;

struct SPIRV_Cross_Input
{
    float3 inputPosition : TEXCOORD0;
    float3 inputUVW : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float3 UVW : TEXCOORD0;
    float4 gl_Position : SV_Position;
};

void vert_main()
{
    gl_Position = float4(inputPosition, 1.0f);
    UVW = inputUVW;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    inputPosition = stage_input.inputPosition;
    inputUVW = stage_input.inputUVW;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    stage_output.UVW = UVW;
    return stage_output;
}
