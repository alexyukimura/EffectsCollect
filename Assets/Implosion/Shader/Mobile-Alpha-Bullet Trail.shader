// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Topameng/Transparent/Bullet Trail" 
{
	Properties 
	{
		_MainTex ("Base layer (RGB)", 2D) = "white" {}
		_DetailTex ("2nd layer (RGB)", 2D) = "white" {}
		_ScrollX ("Base layer Scroll speed X", Float) = 1.0
		_ScrollY ("Base layer Scroll speed Y", Float) = 0.0
		_Scroll2X ("2nd layer Scroll speed X", Float) = 1.0
		_Scroll2Y ("2nd layer Scroll speed Y", Float) = 0.0
		_AMultiplier ("Layer Multiplier", Float) = 0.5
		_TintColor("Tint color",Color) = (1,1,1,1)
	}

	SubShader 
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	
		Blend One One
		ZWrite Off	
		Lighting Off 			
		LOD 100		

		Pass 
		{
			CGPROGRAM
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest		
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Globals.cginc"

			sampler2D _MainTex;
			sampler2D _DetailTex;

			float4 _MainTex_ST;
			float4 _DetailTex_ST;
	
			float _ScrollX;
			float _ScrollY;
			float _Scroll2X;
			float _Scroll2Y;
			float _AMultiplier;
			float4 _TintColor;
	
			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				fixed4 color : TEXCOORD2;		
			};

	
			v2f vert (appdata_color v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex) + frac(float2(_ScrollX, _ScrollY) * _Time);
				o.uv2 = TRANSFORM_TEX(v.texcoord.xy, _DetailTex) + frac(float2(_Scroll2X, _Scroll2Y) * _Time);
				o.color = v.color * _TintColor * _TintColor.a * 2;
				o.color.xyz *= _AMultiplier;

				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{				
				fixed4 tex = tex2D (_MainTex, i.uv);
				fixed4 tex2 = tex2D (_DetailTex, i.uv2);			
				fixed4 o = (tex + tex2) * tex.r * i.color;			
				return o;
			}
			ENDCG 
		}	
	}
}
