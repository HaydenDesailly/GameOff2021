// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Fire Pool"
{
	Properties
	{
		_FalloffTex("FalloffTex", 2D) = "white" {}
		_FallOffIntensity("FallOff Intensity", Float) = 20
		_LightMask("Light Mask", 2D) = "white" {}
		_backgroundNoise("background Noise", 2D) = "white" {}
		_BackgroundTiling("Background Tiling", Vector) = (0,0,0,0)
		_BackgroundSpeed("Background Speed", Range( 0 , 1)) = 0
		_BackgroundColour("Background Colour", Color) = (1,1,1,1)
		_BackgroundAmount("Background Amount", Range( 0 , 1)) = 0
		_Noise1("Noise 1", 2D) = "white" {}
		_Noise1Tiling("Noise 1 Tiling", Range( 0 , 20)) = 1
		_Noise1Speed("Noise 1 Speed", Range( 0 , 10)) = 1
		_Noise1BaseColour("Noise 1 Base Colour", Color) = (1,1,1,1)
		_BaseAmount("Base Amount", Range( 0 , 10)) = 1
		[HDR]_Noise1TipColour("Noise 1 Tip Colour", Color) = (1,1,1,1)
		_TipAmount("Tip Amount", Range( 0 , 1)) = 0.1
		_Noise2("Noise 2", 2D) = "white" {}
		_Noise2Tiling("Noise 2 Tiling", Range( 0 , 20)) = 1
		_Noise2Speed("Noise 2 Speed", Range( 0 , 10)) = 1
		_Distortionnoise("Distortion noise", 2D) = "bump" {}
		_DistortionTiling("Distortion Tiling", Vector) = (1,1,0,0)
		_DistortionSpeed1(" Distortion Speed 1", Vector) = (1,0,0,0)
		_DistortionSpeed2(" Distortion Speed 2", Vector) = (1,0,0,0)
		_DistortionStrength("Distortion Strength", Range( 0 , 100)) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend DstColor One
		AlphaToMask Off
		Cull Back
		ColorMask RGB
		ZWrite Off
		ZTest LEqual
		Offset -1 , -1
		
		
		
		Pass
		{
			Name "SubShader 0 Pass 0"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_VERT_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Noise1BaseColour;
			uniform sampler2D _Noise1;
			uniform float _Noise1Speed;
			float4x4 unity_Projector;
			uniform float _Noise1Tiling;
			uniform sampler2D _Distortionnoise;
			uniform float2 _DistortionSpeed2;
			uniform float2 _DistortionTiling;
			uniform float2 _DistortionSpeed1;
			uniform float _DistortionStrength;
			uniform sampler2D _Noise2;
			uniform float _Noise2Speed;
			uniform float _Noise2Tiling;
			uniform float _BaseAmount;
			uniform float4 _Noise1TipColour;
			uniform float _TipAmount;
			uniform float4 _BackgroundColour;
			uniform sampler2D _backgroundNoise;
			uniform float _BackgroundSpeed;
			uniform float2 _BackgroundTiling;
			uniform float _BackgroundAmount;
			uniform sampler2D _LightMask;
			uniform sampler2D _FalloffTex;
			float4x4 unity_ProjectorClip;
			uniform float _FallOffIntensity;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 vertexToFrag417 = mul( unity_Projector, v.vertex );
				o.ase_texcoord1 = vertexToFrag417;
				float4 vertexToFrag410 = mul( unity_ProjectorClip, v.vertex );
				o.ase_texcoord2 = vertexToFrag410;
				
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 temp_cast_0 = (_Noise1Speed).xx;
				float4 vertexToFrag417 = i.ase_texcoord1;
				float2 LightTexUVVar429 = ( (vertexToFrag417).xy / (vertexToFrag417).w );
				float2 panner484 = ( _SinTime.w * temp_cast_0 + ( LightTexUVVar429 * _Noise1Tiling ));
				float2 panner465 = ( _Time.y * _DistortionSpeed2 + LightTexUVVar429);
				float2 panner452 = ( _Time.y * _DistortionSpeed1 + LightTexUVVar429);
				float3 temp_output_456_0 = ( ( UnpackNormal( tex2D( _Distortionnoise, ( panner465 * _DistortionTiling ) ) ) * UnpackNormal( tex2D( _Distortionnoise, ( panner452 * _DistortionTiling ) ) ) ) * _DistortionStrength );
				float3 DistortionMask475 = temp_output_456_0;
				float3 temp_output_490_0 = ( DistortionMask475 * 0.5 );
				float2 temp_cast_3 = (_Noise2Speed).xx;
				float2 panner428 = ( _Time.y * temp_cast_3 + ( LightTexUVVar429 * _Noise2Tiling ));
				float4 NoiseMasks493 = ( tex2D( _Noise1, ( float3( panner484 ,  0.0 ) + temp_output_490_0 ).xy ) * tex2D( _Noise2, ( float3( panner428 ,  0.0 ) + temp_output_490_0 ).xy ) );
				float4 temp_cast_6 = (( ( 1.0 - _TipAmount ) * (_SinTime.w*0.25 + 0.5) )).xxxx;
				float4 temp_cast_7 = (1.0).xxxx;
				float4 smoothstepResult443 = smoothstep( temp_cast_6 , temp_cast_7 , NoiseMasks493);
				float4 lerpResult449 = lerp( ( ( _Noise1BaseColour * NoiseMasks493 ) * _BaseAmount ) , _Noise1TipColour , smoothstepResult443);
				float2 panner515 = ( ( _SinTime.x * _BackgroundSpeed ) * float2( 2,1 ) + LightTexUVVar429);
				float4 lerpResult513 = lerp( lerpResult449 , _BackgroundColour , ( tex2D( _backgroundNoise, ( panner515 * _BackgroundTiling ) ) * _BackgroundAmount ));
				float4 LightMask473 = ( tex2D( _LightMask, ( float3( LightTexUVVar429 ,  0.0 ) + temp_output_456_0 ).xy ) * tex2D( _LightMask, LightTexUVVar429 ) );
				float4 appendResult406 = (float4(( float4( (lerpResult513).rgb , 0.0 ) * LightMask473 ).rgb , ( 1.0 - LightMask473 ).r));
				float4 vertexToFrag410 = i.ase_texcoord2;
				
				
				finalColor = ( appendResult406 * ( tex2D( _FalloffTex, ( (vertexToFrag410).xy / (vertexToFrag410).w ) ).a * _FallOffIntensity ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18921
978;73;1647;1025;122.0997;2345.536;1.3;True;False
Node;AmplifyShaderEditor.PosVertexDataNode;420;555.8979,427.3271;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnityProjectorMatrixNode;421;555.8979,347.3271;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;422;763.898,347.3271;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexToFragmentNode;417;907.8979,347.3271;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;418;1147.898,347.3271;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;419;1147.898,427.3271;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;423;1387.898,347.3271;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;429;1598.265,454.3671;Inherit;False;LightTexUVVar;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;464;-2817.137,-1183.006;Inherit;False;Property;_DistortionSpeed2; Distortion Speed 2;21;0;Create;True;0;0;0;False;0;False;1,0;-0.005,-0.01;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;453;-2695.826,-659.8337;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;458;-2896.379,-805.8408;Inherit;False;Property;_DistortionSpeed1; Distortion Speed 1;20;0;Create;True;0;0;0;False;0;False;1,0;0.02,0.03;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;463;-2775.763,-1019.432;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;455;-2802.96,-926.0681;Inherit;False;429;LightTexUVVar;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;465;-2435.657,-1212;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;452;-2536.877,-830.6428;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;470;-2504.909,-1021.382;Inherit;False;Property;_DistortionTiling;Distortion Tiling;19;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexturePropertyNode;461;-2607.058,-1433.89;Inherit;True;Property;_Distortionnoise;Distortion noise;18;0;Create;True;0;0;0;False;0;False;None;dd2fd2df93418444c8e280f1d34deeb5;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;472;-2259.732,-856.8829;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;471;-2172.874,-1208.687;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;462;-1963.481,-1232.974;Inherit;True;Property;_TextureSample2;Texture Sample 2;8;0;Create;True;0;0;0;False;0;False;-1;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;450;-2044.259,-905.3024;Inherit;True;Property;_TextureSample1;Texture Sample 1;8;0;Create;True;0;0;0;False;0;False;-1;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;457;-1685.517,-828.2424;Inherit;False;Property;_DistortionStrength;Distortion Strength;22;0;Create;True;0;0;0;False;0;False;0;33.7;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;466;-1661.734,-1073.098;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;456;-1442.893,-954.9705;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;430;-1774.353,-1794.046;Inherit;False;429;LightTexUVVar;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;434;-1657.396,-1997.358;Inherit;False;Property;_Noise1Tiling;Noise 1 Tiling;9;0;Create;True;0;0;0;False;0;False;1;0.2;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;480;-1827.939,-1648.231;Inherit;False;Property;_Noise2Tiling;Noise 2 Tiling;16;0;Create;True;0;0;0;False;0;False;1;2;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;475;-1278.596,-804.0168;Inherit;False;DistortionMask;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;479;-1759.532,-2235.51;Inherit;False;429;LightTexUVVar;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;441;-1378.71,-2121.669;Inherit;False;Property;_Noise1Speed;Noise 1 Speed;10;0;Create;True;0;0;0;False;0;False;1;0.1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;433;-1511.403,-1805.615;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;476;-1014.881,-1557.118;Inherit;False;475;DistortionMask;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinTimeNode;503;-1251.532,-1952.33;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;491;-889.6685,-1449.089;Inherit;False;Constant;_Float2;Float 2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;483;-1496.582,-2247.079;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;478;-1319.606,-1576.684;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;482;-1352.904,-1703.593;Inherit;False;Property;_Noise2Speed;Noise 2 Speed;17;0;Create;True;0;0;0;False;0;False;1;0.35;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;490;-763.0415,-1641.568;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;484;-1036.86,-2244.179;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;2,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;428;-1051.681,-1802.715;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;2,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;477;-700.221,-1835.677;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;486;-685.3994,-2277.141;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;487;-498.8817,-2255.579;Inherit;True;Property;_Noise1;Noise 1;8;0;Create;True;0;0;0;False;0;False;-1;None;3395b5ec6992d7747886f0fc0fada017;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;526;-474.9403,-1878.022;Inherit;True;Property;_Noise2;Noise 2;15;0;Create;True;0;0;0;False;0;False;-1;None;4de34781e8478bc4cb01409517d18c18;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinTimeNode;517;-342.0405,-1278.288;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;522;-222.9936,-1129.479;Inherit;False;Property;_BackgroundSpeed;Background Speed;5;0;Create;True;0;0;0;False;0;False;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;492;-92.47707,-1933.158;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;444;217.9166,-2306.983;Inherit;False;Property;_TipAmount;Tip Amount;14;0;Create;True;0;0;0;False;0;False;0.1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;511;-201.5829,-1423.252;Inherit;False;429;LightTexUVVar;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;493;115.6404,-1946.908;Inherit;False;NoiseMasks;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;521;-53.99359,-1252.479;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;496;365.2638,-2127.883;Inherit;True;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;501;590.2638,-2290.883;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;402;965.8258,-1837.328;Float;False;Property;_Noise1BaseColour;Noise 1 Base Colour;11;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,0.02740604,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;494;635.7502,-1636.08;Inherit;False;493;NoiseMasks;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;500;650.2638,-2122.883;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;431;-1356.692,-1081.214;Inherit;False;429;LightTexUVVar;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;515;105.8213,-1422.204;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;2,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;519;221.4595,-1151.889;Inherit;False;Property;_BackgroundTiling;Background Tiling;4;0;Create;True;0;0;0;False;0;False;0,0;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;528;1132.4,-1527.837;Inherit;False;Property;_BaseAmount;Base Amount;12;0;Create;True;0;0;0;False;0;False;1;6.33;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;442;1208.159,-1647.431;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;445;986.9189,-2083.984;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;498;870.2638,-2278.883;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;518;387.8594,-1333.889;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;413;752.0073,-154.4919;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;468;-1325.248,-1374.549;Inherit;True;Property;_LightMask;Light Mask;2;0;Create;True;0;0;0;False;0;False;None;5228a04ef529d2641937cab585cc1a02;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.UnityProjectorClipMatrixNode;414;752.0073,-234.4919;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;451;-1111.812,-1040.6;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;443;1164.116,-2178.984;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;415;960.0073,-234.4919;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;469;-924.1829,-906.4302;Inherit;True;Property;_TextureSample3;Texture Sample 3;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;447;1457.826,-2162.428;Float;False;Property;_Noise1TipColour;Noise 1 Tip Colour;13;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;47.93726,16.06275,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;510;438.4222,-1552.399;Inherit;True;Property;_backgroundNoise;background Noise;3;0;Create;True;0;0;0;False;0;False;-1;None;2b0086300d829eb4caeefb0d818307cc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;512;659.4191,-1242.839;Inherit;False;Property;_BackgroundAmount;Background Amount;7;0;Create;True;0;0;0;False;0;False;0;0.297;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;527;1410.6,-1651.336;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;416;-917.4693,-1257.503;Inherit;True;Property;_LightTex;LightTex;0;0;Create;True;0;0;0;False;0;False;-1;None;5228a04ef529d2641937cab585cc1a02;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;514;1496.689,-1483.317;Float;False;Property;_BackgroundColour;Background Colour;6;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.07843129,0.02352941,0.3607842,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;509;884.2705,-1457.956;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexToFragmentNode;410;1104.007,-234.4919;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;449;1702.816,-1642.077;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;467;-529.6071,-1099.441;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;412;1344.007,-234.4919;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;513;1799.749,-1367.22;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;411;1344.007,-154.4919;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;473;-311.5431,-964.2013;Inherit;False;LightMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;474;1839.294,-495.4778;Inherit;False;473;LightMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;409;1584.007,-234.4919;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;403;1803.604,-740.9097;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;405;2064.007,-634.4919;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;424;2143.51,-436.9556;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;408;1728.007,-234.4919;Inherit;True;Property;_FalloffTex;FalloffTex;0;0;Create;True;0;0;0;False;0;False;-1;None;62010525e97e86644b7706ffa8f3a162;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;425;1938.605,46.48529;Inherit;False;Property;_FallOffIntensity;FallOff Intensity;1;0;Create;True;0;0;0;False;0;False;20;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;426;2200.137,-175.8995;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;406;2240.007,-586.4919;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;407;2432.007,-362.4919;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;401;2614.625,-344.5562;Float;False;True;-1;2;ASEMaterialInspector;100;1;Fire Pool;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;SubShader 0 Pass 0;2;True;True;1;2;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;True;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;0;False;-1;True;True;-1;False;-1;-1;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;422;0;421;0
WireConnection;422;1;420;0
WireConnection;417;0;422;0
WireConnection;418;0;417;0
WireConnection;419;0;417;0
WireConnection;423;0;418;0
WireConnection;423;1;419;0
WireConnection;429;0;423;0
WireConnection;465;0;455;0
WireConnection;465;2;464;0
WireConnection;465;1;463;0
WireConnection;452;0;455;0
WireConnection;452;2;458;0
WireConnection;452;1;453;0
WireConnection;472;0;452;0
WireConnection;472;1;470;0
WireConnection;471;0;465;0
WireConnection;471;1;470;0
WireConnection;462;0;461;0
WireConnection;462;1;471;0
WireConnection;450;0;461;0
WireConnection;450;1;472;0
WireConnection;466;0;462;0
WireConnection;466;1;450;0
WireConnection;456;0;466;0
WireConnection;456;1;457;0
WireConnection;475;0;456;0
WireConnection;433;0;430;0
WireConnection;433;1;480;0
WireConnection;483;0;479;0
WireConnection;483;1;434;0
WireConnection;490;0;476;0
WireConnection;490;1;491;0
WireConnection;484;0;483;0
WireConnection;484;2;441;0
WireConnection;484;1;503;4
WireConnection;428;0;433;0
WireConnection;428;2;482;0
WireConnection;428;1;478;0
WireConnection;477;0;428;0
WireConnection;477;1;490;0
WireConnection;486;0;484;0
WireConnection;486;1;490;0
WireConnection;487;1;486;0
WireConnection;526;1;477;0
WireConnection;492;0;487;0
WireConnection;492;1;526;0
WireConnection;493;0;492;0
WireConnection;521;0;517;1
WireConnection;521;1;522;0
WireConnection;501;0;444;0
WireConnection;500;0;496;4
WireConnection;515;0;511;0
WireConnection;515;1;521;0
WireConnection;442;0;402;0
WireConnection;442;1;494;0
WireConnection;498;0;501;0
WireConnection;498;1;500;0
WireConnection;518;0;515;0
WireConnection;518;1;519;0
WireConnection;451;0;431;0
WireConnection;451;1;456;0
WireConnection;443;0;494;0
WireConnection;443;1;498;0
WireConnection;443;2;445;0
WireConnection;415;0;414;0
WireConnection;415;1;413;0
WireConnection;469;0;468;0
WireConnection;469;1;431;0
WireConnection;510;1;518;0
WireConnection;527;0;442;0
WireConnection;527;1;528;0
WireConnection;416;0;468;0
WireConnection;416;1;451;0
WireConnection;509;0;510;0
WireConnection;509;1;512;0
WireConnection;410;0;415;0
WireConnection;449;0;527;0
WireConnection;449;1;447;0
WireConnection;449;2;443;0
WireConnection;467;0;416;0
WireConnection;467;1;469;0
WireConnection;412;0;410;0
WireConnection;513;0;449;0
WireConnection;513;1;514;0
WireConnection;513;2;509;0
WireConnection;411;0;410;0
WireConnection;473;0;467;0
WireConnection;409;0;412;0
WireConnection;409;1;411;0
WireConnection;403;0;513;0
WireConnection;405;0;403;0
WireConnection;405;1;474;0
WireConnection;424;0;474;0
WireConnection;408;1;409;0
WireConnection;426;0;408;4
WireConnection;426;1;425;0
WireConnection;406;0;405;0
WireConnection;406;3;424;0
WireConnection;407;0;406;0
WireConnection;407;1;426;0
WireConnection;401;0;407;0
ASEEND*/
//CHKSM=304F05335D7C152C3B8E72BAE32C38E78B75305D