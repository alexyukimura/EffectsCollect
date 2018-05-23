Shader "QQ/DoubleFishEyeSimple"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Lerp("lerp",Range(0,1)) = 1
		_Radius("radius",Range(0.0,1.0)) = 0.5
		_Blend("blend",Range(0,1)) = 0.1
		[Toggle]_Hint("show hint", float) = 0
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
			uniform float _Blend;
			uniform float _Hint;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);   //UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			float3 pts(float2 uv,float r)
			{
				uv = (uv / 1.0 - 0.5)*UNITY_PI;
				return r * float3(sin(uv.x)*cos(uv.y), sin(uv.y), cos(uv.x) * cos(uv.y));
			}

			float2 stp(float3 s,float r)
			{
				float t = atan2(s.y, s.x);
				float p = atan2(sqrt(s.x*s.x + s.y*s.y), s.z);
				float _r = r * 2 * p / UNITY_PI;
				return _r * float2(cos(t), sin(t));
			}

			float2 ptstp(float2 uv, float r,float2 o)
			{
				float3 s = pts(uv, _Radius);
				float2 _uv = stp(s, _Radius);
				_uv.x /= 2;
				return _uv += o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				i.uv = abs(i.uv) % 1.0;
				float2 uv = float2((i.uv.x % 0.5) / 0.5,i.uv.y);
				float m = _Blend + 1;
				float2 _uv = float2(uv.x / m, uv.y);
				float2 uv0 = ptstp(_uv,_Radius, float2(i.uv.x > 0.5 ? 0.75 : 0.25, 0.5));
				fixed4 col = tex2D(_MainTex, lerp(i.uv, uv0, _Lerp), 0, 0);
				if (_Blend > 0.0)
				{
					m = 1 - 1 / m;
					if (_uv.x < m)
					{
						float2 uv1 = ptstp(_uv - float2(1 + m,0), _Radius, float2(i.uv.x > 0.5 ? 0.25 : 0.75, 0.5));
						fixed4 _col = tex2D(_MainTex, lerp(i.uv, uv1, _Lerp), 0, 0);
						col = lerp(col, _col, (m - _uv.x) / m);
					}
				}
				if (_Hint > 0)
				{
					float2 s0 = uv - float2(0.5, 0.5);
					if (length(s0) < _Radius)
						col += fixed4(0.5, 0, 0, 1);
				}
				return col;
			}
			ENDCG
		}
	}
}