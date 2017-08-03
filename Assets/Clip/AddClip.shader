﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
Shader "ProYuki/RimAddClip"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (0.5,0.5,0.5,0.5)
		_ClipY("剔除 Y 值", Range(0,2.0)) = 0
		_RimPower("FresnelPower",Range(0.1,3)) = 2
	}
	
	SubShader
	{
		Tags
		{ 
			"Queue" = "Transparent" 
			"IgnoreProjector" = "True" 
			"RenderType" = "Transparent" 
		}
		
		Cull Back
		Blend SrcAlpha One
		
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
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				float3 normal :NORMAL;
			};

			sampler2D _MainTex;
			fixed4 _Color;
			float _ClipY;
			float _RimPower;

			v2f vert(appdata v)
			{
				v2f o = (v2f)0;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				//计算模型的真正世界坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 viewDir = normalize( UnityWorldSpaceViewDir(i.worldPos) );
				float rim = 1.0 - saturate( dot( i.normal, normalize(viewDir) ) );
				rim = pow(rim, _RimPower);
				clip(_ClipY - i.worldPos.y);
				fixed4 col = tex2D(_MainTex, i.uv)*_Color;
				return col*rim;
			}
			ENDCG
		}
	}
}
