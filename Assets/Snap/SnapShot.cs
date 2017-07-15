using UnityEngine;
using System.Collections;
using System.Text.RegularExpressions;
using System;

public class SnapShot : MonoBehaviour
{
    public int resWidth = 0;
    public int resHeight = 0;
    public string path = "";

    Camera camera;
    // Use this for initialization
    void Start ()
    {
        camera = this.GetComponent<Camera>();
        if (string.IsNullOrEmpty(path))
        {
            path = Application.dataPath;
        }
    }

    void OnGUI()
    {
        GUILayout.BeginArea( new Rect(100, 100, 100, 100) );
        if (GUILayout.Button("Snap"))
        {
            ScreenSnap();
        }
        GUILayout.EndArea();
    }

    void ScreenSnap()
    {
        RenderTexture rt = new RenderTexture(resWidth, resHeight, 24);
        camera.targetTexture = rt;
        Texture2D screenShot = new Texture2D(resWidth, resHeight, TextureFormat.RGB24, false);
        camera.Render();
        RenderTexture.active = rt;
        screenShot.ReadPixels(new Rect(0, 0, resWidth, resHeight), 0, 0);

        byte[] bytes = screenShot.EncodeToPNG();
        string filename = ScreenShotName(resWidth, resHeight);
        Debug.Log(filename);
        System.IO.File.WriteAllBytes(filename, bytes);

        camera.targetTexture = null;
        RenderTexture.active = null; // JC: added to avoid errors
        Destroy(rt);
    }

    string ScreenShotName(int width, int height)
    {
        //"I:\\Work\\screen_{0}x{1}_{2}.png"
        return string.Format(path,
                             width, height,
                             System.DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss"));
    }
}
