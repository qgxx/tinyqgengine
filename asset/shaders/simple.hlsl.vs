#include "cbuffer2.h"
#include "vsoutput2.hs"
#include "illum.hs"

v2p VSMain(a2v input) {
    v2p output;

	output.Position = mul(mul(mul(float4(input.Position.xyz, 1.0f), m_model), m_view), m_projection);
	float3 vN = normalize(mul(mul(float4(input.Normal, 0), m_model), m_view).xyz);
	float3 vT = normalize(mul(mul(float4(input.Tangent.xyz, 0), m_model), m_view).xyz);
	output.vPosInView = mul(mul(float4(input.Position.xyz, 1.0f), m_model), m_view).xyz;

	output.vNorm = vN;
	output.vTang = float4(vT, input.Tangent.w);

	output.TextureUV = input.TextureUV;

	return output;
}