using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using static Unity.Burst.Intrinsics.X86.Avx;

public class ScreenSpaceShadowMap : MonoBehaviour
{
    public RenderTexture globalShadowTexture;


    // Start is called before the first frame update
    void Start()
    {
        Light light = GetComponent<Light>();

        // Create a command buffer
        CommandBuffer cmd = new CommandBuffer();
        cmd.name = "Shadow Texture";

        cmd.SetGlobalTexture("_MyScreenSpaceShadows", BuiltinRenderTextureType.CurrentActive);
        light.AddCommandBuffer(LightEvent.AfterScreenspaceMask, cmd);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
