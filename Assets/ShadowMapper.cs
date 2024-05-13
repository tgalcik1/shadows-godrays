using UnityEngine.Rendering;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class ShadowMapper : MonoBehaviour
{
    #region ❐  Properties and fields

    public RenderTexture ShadowmapCopy;
    private Camera _camera;


    #endregion
    private void OnEnable()
    {
        RenderPipelineManager.endCameraRendering += CameraRender;
        _camera = GetComponent<Camera>();
    }

    // Unity calls this method automatically when it disables this component
    private void OnDisable()
    {
        RenderPipelineManager.endCameraRendering -= CameraRender;
    }

    void CameraRender(ScriptableRenderContext context, Camera camera)
    {
        if (camera != _camera) return;

        var rt = (RenderTexture)Shader.GetGlobalTexture("_ScreenSpaceShadowmapTexture");
        if (rt == null) return;

        CommandBuffer myCommandBuffer = new CommandBuffer();
        myCommandBuffer.Blit(rt, ShadowmapCopy);

        context.ExecuteCommandBuffer(myCommandBuffer);
    }


}