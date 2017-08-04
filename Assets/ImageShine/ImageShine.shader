Shader "PK/ImageShine"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
		_Percent("Percent", Range(-5,5)) = 1
		_WidRatio("Width", Range(0,20)) = 1
		_Rotate("Rotate",Range(0,3.14)) = 0.866

		_Angle("CDAngle", Range(0, 1)) = 0
		_AlphaScale("Alpha",Range(0,1)) = 0.3
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "true" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert        
			#pragma fragment frag        
			#pragma fragmentoption ARB_precision_hint_fastest 
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			float _Percent;
			float _WidRatio;
			float _Rotate;

			float _Angle;
			float _AlphaScale;

			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			v2f vert( appdata_base v)
			{
				v2f o = (v2f)0;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord.xy;
				return o;
			}

			fixed4 frag(v2f i):COLOR0
			{
				// 计算圆角  
				float2 uv = i.uv.xy - float2(0.5,0.5);
				float rx = fmod(uv.x , 0.4);
				float ry = fmod(uv.y , 0.4);
				float mx = step(0.4, abs(uv.x));
				float my = step(0.4, abs(uv.y));
				float alpha = 1 - mx*my*step( 0.1, length( half2(rx,ry) ) );
				fixed2x2  rotMat = fixed2x2(_Rotate, 0.5, -0.5, _Rotate);  // 旋转矩阵，旋转30度  
				fixed4 k = tex2D(_MainTex, i.uv);
				//k = fixed4( fixed3(k.r / 3,k.g / 3,k.b / 3), 1);  //灰度设置   
				uv = i.uv - fixed2(0.5,0.5);
				_Angle = 6.283*(0.5-_Angle); //2*3.14
				float hui = (2 - sign(_Angle - atan2(uv.y, uv.x))) / 3;// 百分比计算 
				uv = (i.uv + fixed2(_Percent, _Percent) - 1) * _WidRatio;// 缩放并位移  
				uv = mul(rotMat, uv);//旋转

				fixed v = saturate( lerp(fixed(1), fixed(0), abs(uv.y)) );
				if ( k.a > 0.05 )
				{
					k += fixed4(v, v, v, v);// 加上光线 
				}	
				k = k *1.3 - _AlphaScale*fixed4(fixed3(hui, hui, hui), alpha); // 圆角的运用  
				//k *= fixed4( fixed3(hui,hui,hui), alpha );// 圆角的运用    
				return k;
			}
			ENDCG
		}
	}
    FallBack Off
}
