Shader "QQ/TexConvert/SingleFishEyeSimple"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Lerp("lerp",Range(0,1)) = 1
		_Radius("radius",Range(0.0,1.0)) = 0.5
		[Toggle] _Hint("show hint", float) = 0
	}
	
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _Lerp;
			uniform float _Radius;
			uniform float _Hint;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				i.uv = abs(i.uv) % 1.0;
				float th = i.uv.x *  UNITY_PI * 2;
				float ta = tan(th);
				float2 uv0 = float2(cos(th)*ta*_Radius, sin(th) / ta*_Radius)*(1 - i.uv.y) + 0.5;
				fixed4 col = tex2D(_MainTex, lerp(i.uv, uv0, _Lerp), 0, 0);
				if (_Hint > 0)
				{
					if (length(i.uv - float2(0.5, 0.5)) < _Radius)
						col += fixed4(uv0, 0, 1);
				}
				return col;
			}
			ENDCG
		}
	}
}