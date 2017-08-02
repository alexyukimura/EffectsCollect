using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class BlurEffect : MonoBehaviour
{
    public Material blurMat;
    public float offset;
    public int times = 3;
    public bool useBlur;

    private RenderTexture rt;

    void OnDisable()
    {
        if (rt != null)
        {
            DestroyImmediate(rt);
            rt = null;
        }
    }

    bool InitRT()
    {
        if (rt == null)
        {
            if (GetComponent<Camera>().targetTexture == null)
                return false;
        }
        else
            rt = new RenderTexture(GetComponent<Camera>().targetTexture.width, GetComponent<Camera>().targetTexture.height, 24);
        return true;
    }
	

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        if (!InitRT()) return;
        if (blurMat == null)
            Graphics.Blit(src, dst);
        else
        {
            if (!useBlur)
            {
                Graphics.Blit(src, dst);
                return;
            }
            blurMat.SetFloat("offset", offset);
            RenderTexture rt = RenderTexture.GetTemporary(src.width / 4, src.height / 4, 0);
            Graphics.Blit(src, rt, blurMat);
            for (int i = 0; i <= times; i++)
            {
                RenderTexture rt2 = RenderTexture.GetTemporary(src.width / 4, src.height / 4, 0);
                Graphics.Blit(rt, rt2, blurMat);
                RenderTexture.ReleaseTemporary(rt);
                rt = rt2;
            }
            Graphics.Blit(rt, dst, blurMat);
            RenderTexture.ReleaseTemporary(rt);
        }
    }
}
