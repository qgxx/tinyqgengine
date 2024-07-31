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

cbuffer PerFrameConstants : register(b0, space0)
{
    row_major float4x4 _30_viewMatrix : packoffset(c0);
    row_major float4x4 _30_projectionMatrix : packoffset(c4);
    float4 _30_camPos : packoffset(c8);
    int _30_numLights : packoffset(c9);
    Light _30_allLights[100] : packoffset(c10);
};


static float4 gl_Position;
static float3 UVW;
static float3 inputPosition;

struct SPIRV_Cross_Input
{
    float3 inputPosition : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float3 UVW : TEXCOORD0;
    float4 gl_Position : SV_Position;
};

void vert_main()
{
    UVW = inputPosition;
    float4x4 _matrix = _30_viewMatrix;
    _matrix[3].x = 0.0f;
    _matrix[3].y = 0.0f;
    _matrix[3].z = 0.0f;
    float4 pos = mul(float4(inputPosition, 1.0f), mul(_matrix, _30_projectionMatrix));
    gl_Position = pos.xyww;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    inputPosition = stage_input.inputPosition;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    stage_output.UVW = UVW;
    return stage_output;
}
