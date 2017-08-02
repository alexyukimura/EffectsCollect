using UnityEngine;

[ExecuteInEditMode]
public class PJShadow : MonoBehaviour
{
    public float shadowSize = 1;
    public int blurTimes = 3;
    public float blurOffset;
    public Material blurMat;
    public bool useBlur;
    static bool isRendering;
    Camera curCam;
    RenderTexture shadowTex;

    void OnEnable()
    {
        RenderObjects();
    }

    void OnDisable()
    {
        Clear();
    }

    void OnGUI()
    {
        //GUI.DrawTexture(new Rect(0, 0, Screen.width * 0.8f, Screen.height * 0.8f), shadowTex);
    }

    void Clear()
    {
        if (shadowTex)
        {
            DestroyImmediate(shadowTex);
            shadowTex = null;
        }
    }

    Camera CreateLightSpaceCam(Material mat)
    {
        if (!shadowTex)
        {
            if (shadowTex) DestroyImmediate(shadowTex);
            shadowTex = new RenderTexture((int)(Screen.width * shadowSize), (int)(Screen.height * shadowSize), 0);
            shadowTex.hideFlags = HideFlags.DontSave;
        }

        Camera result = curCam;
        if (result == null)
        {
            GameObject go = new GameObject("ProjectorCam", typeof(Camera), typeof(BlurEffect));
            go.hideFlags = HideFlags.HideAndDontSave;
            result = go.GetComponent<Camera>();
            result.enabled = false;
            result.transform.localPosition = Vector3.zero;
            result.transform.localRotation = Quaternion.Euler(Vector3.zero);
            result.gameObject.AddComponent<FlareLayer>();
            curCam = result;
        }
        if (mat.HasProperty("_ShadowTex"))
            mat.SetTexture("_ShadowTex", shadowTex);
        return result;
    }

    void UseBlur(BlurEffect blur)
    {
        blur.useBlur = useBlur;
        blur.blurMat = blurMat;
        blur.times = blurTimes;
        blur.offset = blurOffset/128.0f;
    }

    void InitCamera(Camera cam, Projector projector)
    {
        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.backgroundColor = new Color(1, 1, 1, 0);
        cam.farClipPlane = projector.farClipPlane;
        cam.nearClipPlane = projector.nearClipPlane;
        cam.orthographic = projector.orthographic;
        cam.fieldOfView = projector.fieldOfView;
        cam.aspect = projector.aspectRatio;
        cam.orthographicSize = projector.orthographicSize;
        cam.depthTextureMode = DepthTextureMode.None;
        cam.renderingPath = RenderingPath.Forward;
        cam.cullingMask = LayerMask.GetMask("Player");
        //Debug.Log(cam.transform.rotation);
        cam.transform.position = transform.position;
        cam.transform.rotation = transform.rotation;
    }

    void Update()
    {
        RenderObjects();
    }

    void RenderObjects()
    {
        if (isRendering)
            return;
        isRendering = true;
        Projector pj = gameObject.GetComponent<Projector>();
        if (pj == null)
            return;

        Camera pjCam = CreateLightSpaceCam(pj.material);
        if (pjCam == null)
            return;
        InitCamera(pjCam, pj);
        UseBlur(pjCam.GetComponent<BlurEffect>());
        pjCam.Render();
        pjCam.targetTexture = shadowTex;
        isRendering = false;
    }
}
