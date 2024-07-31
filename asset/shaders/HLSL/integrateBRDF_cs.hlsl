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

static const uint3 gl_WorkGroupSize = uint3(1u, 1u, 1u);

RWTexture2D<float2> img_output : register(u0, space0);

static uint3 gl_GlobalInvocationID;
struct SPIRV_Cross_Input
{
    uint3 gl_GlobalInvocationID : SV_DispatchThreadID;
};

float RadicalInverse_VdC(inout uint bits)
{
    bits = (bits << 16u) | (bits >> 16u);
    bits = ((bits & 1431655765u) << 1u) | ((bits & 2863311530u) >> 1u);
    bits = ((bits & 858993459u) << 2u) | ((bits & 3435973836u) >> 2u);
    bits = ((bits & 252645135u) << 4u) | ((bits & 4042322160u) >> 4u);
    bits = ((bits & 16711935u) << 8u) | ((bits & 4278255360u) >> 8u);
    return float(bits) * 2.3283064365386962890625e-10f;
}

float2 Hammersley(uint i, uint N)
{
    uint param = i;
    float _156 = RadicalInverse_VdC(param);
    return float2(float(i) / float(N), _156);
}

float3 ImportanceSampleGGX(float2 Xi, float3 N, float roughness)
{
    float a = roughness * roughness;
    float phi = 6.283185482025146484375f * Xi.x;
    float cosTheta = sqrt((1.0f - Xi.y) / (1.0f + (((a * a) - 1.0f) * Xi.y)));
    float sinTheta = sqrt(1.0f - (cosTheta * cosTheta));
    float3 H;
    H.x = cos(phi) * sinTheta;
    H.y = sin(phi) * sinTheta;
    H.z = cosTheta;
    bool3 _213 = (abs(N.z) < 0.999000012874603271484375f).xxx;
    float3 up = float3(_213.x ? float3(0.0f, 0.0f, 1.0f).x : float3(1.0f, 0.0f, 0.0f).x, _213.y ? float3(0.0f, 0.0f, 1.0f).y : float3(1.0f, 0.0f, 0.0f).y, _213.z ? float3(0.0f, 0.0f, 1.0f).z : float3(1.0f, 0.0f, 0.0f).z);
    float3 tangent = normalize(cross(up, N));
    float3 bitangent = cross(N, tangent);
    float3 sampleVec = ((tangent * H.x) + (bitangent * H.y)) + (N * H.z);
    return normalize(sampleVec);
}

float GeometrySchlickGGXIndirect(float NdotV, float roughness)
{
    float a = roughness;
    float k = (a * a) / 2.0f;
    float nom = NdotV;
    float denom = (NdotV * (1.0f - k)) + k;
    return nom / denom;
}

float GeometrySmithIndirect(float3 N, float3 V, float3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0f);
    float NdotL = max(dot(N, L), 0.0f);
    float param = NdotV;
    float param_1 = roughness;
    float ggx2 = GeometrySchlickGGXIndirect(param, param_1);
    float param_2 = NdotL;
    float param_3 = roughness;
    float ggx1 = GeometrySchlickGGXIndirect(param_2, param_3);
    return ggx1 * ggx2;
}

float2 IntegrateBRDF(float NdotV, float roughness)
{
    float3 V;
    V.x = sqrt(1.0f - (NdotV * NdotV));
    V.y = 0.0f;
    V.z = NdotV;
    float A = 0.0f;
    float B = 0.0f;
    float3 N = float3(0.0f, 0.0f, 1.0f);
    for (uint i = 0u; i < 1024u; i++)
    {
        uint param = i;
        uint param_1 = 1024u;
        float2 Xi = Hammersley(param, param_1);
        float2 param_2 = Xi;
        float3 param_3 = N;
        float param_4 = roughness;
        float3 H = ImportanceSampleGGX(param_2, param_3, param_4);
        float3 L = normalize((H * (2.0f * dot(V, H))) - V);
        float NdotL = max(L.z, 0.0f);
        float NdotH = max(H.z, 0.0f);
        float VdotH = max(dot(V, H), 0.0f);
        if (NdotL > 0.0f)
        {
            float3 param_5 = N;
            float3 param_6 = V;
            float3 param_7 = L;
            float param_8 = roughness;
            float G = GeometrySmithIndirect(param_5, param_6, param_7, param_8);
            float G_Vis = (G * VdotH) / (NdotH * NdotV);
            float Fc = pow(1.0f - VdotH, 5.0f);
            A += ((1.0f - Fc) * G_Vis);
            B += (Fc * G_Vis);
        }
    }
    A /= 1024.0f;
    B /= 1024.0f;
    return float2(A, B);
}

void comp_main()
{
    int2 pixel_coords = int2(gl_GlobalInvocationID.xy);
    float param = float(pixel_coords.x) / float(SPIRV_Cross_NumWorkgroups_count.x);
    float param_1 = float(pixel_coords.y) / float(SPIRV_Cross_NumWorkgroups_count.y);
    float2 _385 = IntegrateBRDF(param, param_1);
    float4 pixel;
    pixel.x = _385.x;
    pixel.y = _385.y;
    img_output[pixel_coords] = pixel.xy;
}

[numthreads(1, 1, 1)]
void main(SPIRV_Cross_Input stage_input)
{
    gl_GlobalInvocationID = stage_input.gl_GlobalInvocationID;
    comp_main();
}
