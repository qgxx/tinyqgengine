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

cbuffer ps_constant_t
{
    float3 u_lightParams_lightPos : packoffset(c0);
    float u_lightParams_far_plane : packoffset(c0.w);
};


static float gl_FragDepth;
static float4 FragPos;

struct SPIRV_Cross_Input
{
    float4 FragPos : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float gl_FragDepth : SV_Depth;
};

void frag_main()
{
    float lightDistance = length(FragPos.xyz - u_lightParams_lightPos);
    lightDistance /= u_lightParams_far_plane;
    gl_FragDepth = lightDistance;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    FragPos = stage_input.FragPos;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_FragDepth = gl_FragDepth;
    return stage_output;
}
