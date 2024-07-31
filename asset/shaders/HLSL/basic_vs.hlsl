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
    row_major float4x4 _13_modelMatrix : packoffset(c0);
};

cbuffer PerFrameConstants : register(b0, space0)
{
    row_major float4x4 _42_viewMatrix : packoffset(c0);
    row_major float4x4 _42_projectionMatrix : packoffset(c4);
    float4 _42_camPos : packoffset(c8);
    int _42_numLights : packoffset(c9);
    Light _42_allLights[100] : packoffset(c10);
};


static float4 gl_Position;
static float4 v_world;
static float3 inputPosition;
static float4 v;
static float4 normal_world;
static float3 inputNormal;
static float4 normal;
static float2 uv;
static float2 inputUV;

struct SPIRV_Cross_Input
{
    float3 inputPosition : TEXCOORD0;
    float3 inputNormal : TEXCOORD1;
    float2 inputUV : TEXCOORD2;
};

struct SPIRV_Cross_Output
{
    float4 normal : TEXCOORD0;
    float4 normal_world : TEXCOORD1;
    float4 v : TEXCOORD2;
    float4 v_world : TEXCOORD3;
    float2 uv : TEXCOORD4;
    float4 gl_Position : SV_Position;
};

void vert_main()
{
    v_world = mul(float4(inputPosition, 1.0f), _13_modelMatrix);
    v = mul(v_world, _42_viewMatrix);
    gl_Position = mul(v, _42_projectionMatrix);
    normal_world = mul(float4(inputNormal, 0.0f), _13_modelMatrix);
    normal = mul(normal_world, _42_viewMatrix);
    uv.x = inputUV.x;
    uv.y = 1.0f - inputUV.y;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    inputPosition = stage_input.inputPosition;
    inputNormal = stage_input.inputNormal;
    inputUV = stage_input.inputUV;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    stage_output.v_world = v_world;
    stage_output.v = v;
    stage_output.normal_world = normal_world;
    stage_output.normal = normal;
    stage_output.uv = uv;
    return stage_output;
}
