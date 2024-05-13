#pragma multi_compile _  _MAIN_LIGHT_SHADOWS_CASCADE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//standart hash
real random(real2 p) {
	return frac(sin(dot(p, real2(41, 289)))*45758.5453) - 0.5;
}
real random01(real2 p) {
	return frac(sin(dot(p, real2(41, 289)))*45758.5453);
}

real ShadowAtten(real3 worldPosition)
{
	return MainLightRealtimeShadow(TransformWorldToShadowCoord(worldPosition));
}

//real ComputeScattering(real lightDotView)
//{
//	real _Scattering = -0.4;
//
//	real result = 1.0f - _Scattering * _Scattering;
//	result /= (4.0f * PI * pow(1.0f + _Scattering * _Scattering - (2.0f * _Scattering) *      lightDotView, 1.5f));
//	return result;
//}

real3 GetWorldPos(real2 uv) {
#if UNITY_REVERSED_Z
	real depth = SampleSceneDepth(uv);
#else
	// Adjust z to match NDC for OpenGL
	real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(uv));
#endif
	return ComputeWorldSpacePosition(uv, depth, UNITY_MATRIX_I_VP);
}

real3 ScreenToWorld(float3 UV, float2 Screen)
{
	float2 NDC_XY = float2(2.0 * UV.xy / Screen);
	float3 NDC = float3(NDC_XY, UV.z);

	//float4 p = mul(mul(UNITY_MATRIX_I_P, UNITY_MATRIX_I_V)), float4(NDC, 1.0));
	float4 p = mul(UNITY_I_P, float4(NDC, 1.0));
	float3 World = p.xyz / p.w;

	return World;
}

void Godrays_float(float3 UV, float2 Screen, float3 LightPos, out float3 WorldSpacePos, out float intensity) {
	float3 worldPos = GetWorldPos(UV);

	// convert UV to worldspace

	real3 startPosition = ScreenToWorld(UV, Screen);
	real3 rayVector = worldPos - startPosition;
	real3 rayDirection = normalize(rayVector);
	real rayLength = length(rayVector);

	intensity = ShadowAtten(worldPos);
	WorldSpacePos = startPosition;
}

//void Godrays_float(float2 UV, float3 LightPos, float3 ScreenPosWS, out float3 WorldSpacePos, out float intensity)
//{    
//    // Reconstruct the world space positions.
//	float3 worldPos = GetWorldPos(UV);
//    
//    int _Steps = 24;
//	int _MaxDistance = 40;
//	int _JitterVolumetric = 0;
//
//	real3 startPosition = _WorldSpaceCameraPos; // should start at the near plane instead? with proper uv offset?
//	real3 rayVector = worldPos - startPosition;
//	real3 rayDirection = normalize(rayVector);
//	real rayLength = length(rayVector);
//
//	if (rayLength > _MaxDistance) {
//		rayLength = _MaxDistance;
//		worldPos = startPosition + rayDirection * rayLength;
//	}
//
//	real stepLength = rayLength / _Steps;
//	real3 step = rayDirection * stepLength;
//
//	real rayStartOffset = random01(UV)*stepLength *_JitterVolumetric / 100;
//	real3 currentPosition = startPosition + rayStartOffset * rayDirection;
//
//	real accumFog = 1;
//
//	for (real j = 0; j < _Steps - 1; j++)
//	{
//		real shadowMapValue = ShadowAtten(currentPosition);
//
//		//if it is in light
//		if (shadowMapValue > 0) {
//			/*real kernelColor = ComputeScattering(dot(rayDirection, LightPos));
//			accumFog += kernelColor;*/
//		}
//		else
//		{
//			accumFog -= 1;
//		}
//		currentPosition += step;
//	}
//	//we need the average value, so we divide between the amount of samples 
//	//accumFog /= _Steps;
//
//	intensity = accumFog;
//
//	//intensity = 0;
//	WorldSpacePos = accumFog;
//}