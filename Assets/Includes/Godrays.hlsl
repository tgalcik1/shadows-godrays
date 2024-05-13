void Godrays_float(float2 UV, float3 LightPos, out float3 WorldSpacePos, out float intensity)
{
#if UNITY_REVERSED_Z
        real depth = SampleSceneDepth(UV);
#else
        // Adjust Z to match NDC for OpenGL ([-1, 1])
    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
#endif 
    
    // Reconstruct the world space positions.
    float3 worldPos = ComputeWorldSpacePosition(UV, depth, UNITY_MATRIX_I_VP);
    
    int NumSteps = 4;
    float3 ro = worldPos;
    float3 rd = normalize(LightPos - worldPos);
    float stepSize = length(LightPos - worldPos) / NumSteps;
    
    intensity = 0.0; // Initialize intensity to 0
    
    for (int i = 0; i < NumSteps; i++)
    {
        float3 rayPos = ro + rd * stepSize * i;
        
        //float col = _ShadowMapTexture;
        
        WorldSpacePos = rayPos;
    }
  
}