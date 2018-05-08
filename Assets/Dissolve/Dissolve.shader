Shader "Dissolve"
{
	Properties
	{
		_Color("Color",Color) = (0.5,0.5,0.5,1.0)
		_MainTex("Texture", 2D) = "white" {}
		_EdgeColor("EdgeColor",Color) = (1,0,0,1)
		_Height("Height",float) = 0
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
			// make fog work
			#pragma multi_compile_fog
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float3 wPos:TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			uniform fixed4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _Height;
			uniform fixed4 _EdgeColor;

			float3 hash(float3 p)
			{
				p = float3(dot(p, float3(127.1, 311.7,4560.0)),dot(p, float3(269.5, 183.3,143.15)), dot(p, float3(567.5,613.3,430.4)));
				return  2.0 * frac(sin(p)*43758.5453123) - 1.0;
			}

			float perlin(float3 p)
			{
				float3 i = floor(p);
				float3 f = p - i;
				float3 w = f * f * (3.0 - 2.0 * f);
				float f0 = lerp(lerp(dot(hash(i + float3(0.0, 0.0,0.0)), f - float3(0.0, 0.0,0.0)),dot(hash(i + float3(1.0, 0.0,0.0)), f - float3(1.0, 0.0,0.0)), w.x),lerp(dot(hash(i + float3(0.0, 1.0,0.0)), f - float3(0.0, 1.0,0.0)),dot(hash(i + float3(1.0, 1.0,0.0)), f - float3(1.0, 1.0,0.0)), w.x),w.y);
				float f1 = lerp(lerp(dot(hash(i + float3(0.0, 0.0,1.0)), f - float3(0.0, 0.0,1.0)),dot(hash(i + float3(1.0, 0.0,1.0)), f - float3(1.0, 0.0,1.0)), w.x),lerp(dot(hash(i + float3(0.0, 1.0,1.0)), f - float3(0.0, 1.0,1.0)),dot(hash(i + float3(1.0, 1.0,1.0)), f - float3(1.0, 1.0,1.0)), w.x), w.y);
				return lerp(f0,f1,w.z);
			}

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex); //UnityObjectToClipPos(v.vertex);
				o.wPos = mul(_Object2World, v.vertex).xyz; //unity_ObjectToWorld
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex,i.uv)*_Color;
				float p = perlin(i.wPos * 30) - (i.wPos.y - _Height);
				float e0 = (1 - smoothstep(0, 0.3, p));
				float e1 = (1 - smoothstep(0, 0.1, p));
				col = lerp(col,col * _EdgeColor, e0);
				col = lerp(col, col * _EdgeColor * 2, e1);
				clip(p);
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}