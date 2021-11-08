// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Planar Decal"
{
	Properties
	{
		_Intensity("Intensity", Range( 0 , 10)) = 1
		[HDR]_Color0("Color 0", Color) = (1,0.52,0,0)
		[HDR]_Color2("Color 2", Color) = (1,0.52,0,0)
		[HDR]_Color1("Color 1", Color) = (1,0.52,0,0)
		_NoiseScale("Noise Scale", Range( 0 , 1)) = 0.01
		_StepTest("Step Test", Range( 0 , 1)) = 0
		_StepTest2("Step Test2", Range( 0 , 1)) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend One OneMinusSrcAlpha
		AlphaToMask Off
		Cull Front
		ColorMask RGBA
		ZWrite On
		ZTest Always
		
		
		
		Pass
		{
			Name "Unlit"
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color0;
			uniform float4 _Color2;
			uniform float4 _Color1;
			uniform float _NoiseScale;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _StepTest;
			uniform float _StepTest2;
			uniform float _Intensity;
					float2 voronoihash30( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi30( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash30( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			
			float2 UnStereo( float2 UV )
			{
				#if UNITY_SINGLE_PASS_STEREO
				float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
				UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
				#endif
				return UV;
			}
			
			float3 InvertDepthDir72_g1( float3 In )
			{
				float3 result = In;
				#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
				result *= float3(1,1,-1);
				#endif
				return result;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
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
				float mulTime31 = _Time.y * 3.0;
				float time30 = mulTime31;
				float2 voronoiSmoothId30 = 0;
				float4 screenPos = i.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 UV22_g3 = ase_screenPosNorm.xy;
				float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
				float2 break64_g1 = localUnStereo22_g3;
				float clampDepth69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - clampDepth69_g1 );
				#else
				float staticSwitch38_g1 = clampDepth69_g1;
				#endif
				float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
				float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
				float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
				float3 temp_output_46_0_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
				float3 In72_g1 = temp_output_46_0_g1;
				float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
				float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));
				float4 temp_output_1_0 = mul( unity_CameraToWorld, appendResult49_g1 );
				float3 objToWorldDir32 = mul( unity_ObjectToWorld, float4( temp_output_1_0.xyz, 0 ) ).xyz;
				float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
				float2 coords30 = (( objToWorldDir32 * ase_objectScale )).xz * _NoiseScale;
				float2 id30 = 0;
				float2 uv30 = 0;
				float fade30 = 0.5;
				float voroi30 = 0;
				float rest30 = 0;
				for( int it30 = 0; it30 <3; it30++ ){
				voroi30 += fade30 * voronoi30( coords30, time30, id30, uv30, 0,voronoiSmoothId30 );
				rest30 += fade30;
				coords30 *= 2;
				fade30 *= 0.5;
				}//Voronoi30
				voroi30 /= rest30;
				float temp_output_42_0 = pow( voroi30 , 4.0 );
				float4 lerpResult73 = lerp( _Color2 , _Color1 , step( temp_output_42_0 , ( _StepTest * 0.01 ) ));
				float4 lerpResult65 = lerp( _Color0 , lerpResult73 , step( temp_output_42_0 , ( _StepTest2 * 0.01 ) ));
				float3 worldToObj2 = mul( unity_WorldToObject, float4( temp_output_1_0.xyz, 1 ) ).xyz;
				float mulTime16 = _Time.y * 2.0;
				float mulTime21 = _Time.y * 3.0;
				float mulTime22 = _Time.y * 4.0;
				float mulTime23 = _Time.y * 2.5;
				float4 appendResult20 = (float4(mulTime16 , mulTime21 , mulTime22 , mulTime23));
				float4 break24 = (sin( ( appendResult20 + float4(0,0.1,0.2,0.3) ) )*0.25 + 0.75);
				float temp_output_38_0 = ( saturate( ( 1.0 - pow( length( ( worldToObj2 * 2 ) ) , ( break24.x * break24.y * break24.z * break24.w * _Intensity ) ) ) ) * temp_output_42_0 );
				float4 appendResult6 = (float4(( lerpResult65 * temp_output_38_0 ).rgb , temp_output_38_0));
				
				
				finalColor = appendResult6;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18921
1557;73;1068;1025;2723.839;416.5919;1.6;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;23;-3054.021,350.7751;Inherit;False;1;0;FLOAT;2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;16;-3061.958,100.3082;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;21;-3056.021,181.7749;Inherit;False;1;0;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;22;-3055.021,264.7749;Inherit;False;1;0;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-2822.767,171.7536;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;27;-2760.183,385.9631;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;0;False;0;False;0,0.1,0.2,0.3;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-2553.821,161.5584;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;1;-2143.282,-78.78335;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.ObjectScaleNode;39;-1433.222,629.9836;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;32;-1692.356,384.631;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SinOpNode;17;-2399.053,158.7996;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;18;-2218.823,163.2997;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.25;False;2;FLOAT;0.75;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TransformPositionNode;2;-1770.184,-79.38345;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1345.222,351.9836;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;34;-1194.259,325.181;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;24;-2012.415,153.9663;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;26;-2136.582,447.9837;Inherit;False;Property;_Intensity;Intensity;0;0;Create;True;0;0;0;False;0;False;1;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;3;-1565.484,-69.98336;Inherit;False;2;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;31;-1203.516,447.618;Inherit;False;1;0;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1277.177,551.9933;Inherit;True;Property;_NoiseScale;Noise Scale;4;0;Create;True;0;0;0;False;0;False;0.01;0.019;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-730.3189,511.4989;Inherit;False;Property;_StepTest;Step Test;5;0;Create;True;0;0;0;False;0;False;0;0.031;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;5;-1409.182,-63.18344;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1877.222,152.5368;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;30;-997.6652,331.9077;Inherit;False;0;0;1;0;3;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0.01;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-450.9459,392.8773;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;19;-1192.685,-50.55347;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-373.0888,544.3016;Inherit;False;Property;_StepTest2;Step Test2;6;0;Create;True;0;0;0;False;0;False;0;0.159;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;42;-826.3782,273.5628;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;8;-994.8625,-63.29112;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-54.48294,409.1129;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;64;-332.6082,262.4403;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;48;-510.0868,-274.6663;Inherit;False;Property;_Color1;Color 1;3;1;[HDR];Create;True;0;0;0;False;0;False;1,0.52,0,0;0,55.46667,256,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;74;-701.9548,-465.2036;Inherit;False;Property;_Color2;Color 2;2;1;[HDR];Create;True;0;0;0;False;0;False;1,0.52,0,0;319.8285,0,42.64375,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;9;-813.1124,-69.55009;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;73;-113.6251,-304.7178;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;7;-104.3258,-569.3989;Inherit;False;Property;_Color0;Color 0;1;1;[HDR];Create;True;0;0;0;False;0;False;1,0.52,0,0;766.9961,89.48289,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;66;-76.03706,165.3;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-633.7567,-71.76798;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;65;334.0596,-512.1906;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;410.0173,-40.22644;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;6;484.0228,56.58497;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;45;622.4678,29.73757;Float;False;True;-1;2;ASEMaterialInspector;100;1;Planar Decal;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;20;0;16;0
WireConnection;20;1;21;0
WireConnection;20;2;22;0
WireConnection;20;3;23;0
WireConnection;28;0;20;0
WireConnection;28;1;27;0
WireConnection;32;0;1;0
WireConnection;17;0;28;0
WireConnection;18;0;17;0
WireConnection;2;0;1;0
WireConnection;40;0;32;0
WireConnection;40;1;39;0
WireConnection;34;0;40;0
WireConnection;24;0;18;0
WireConnection;3;0;2;0
WireConnection;5;0;3;0
WireConnection;25;0;24;0
WireConnection;25;1;24;1
WireConnection;25;2;24;2
WireConnection;25;3;24;3
WireConnection;25;4;26;0
WireConnection;30;0;34;0
WireConnection;30;1;31;0
WireConnection;30;2;41;0
WireConnection;59;0;57;0
WireConnection;19;0;5;0
WireConnection;19;1;25;0
WireConnection;42;0;30;0
WireConnection;8;0;19;0
WireConnection;72;0;71;0
WireConnection;64;0;42;0
WireConnection;64;1;59;0
WireConnection;9;0;8;0
WireConnection;73;0;74;0
WireConnection;73;1;48;0
WireConnection;73;2;64;0
WireConnection;66;0;42;0
WireConnection;66;1;72;0
WireConnection;38;0;9;0
WireConnection;38;1;42;0
WireConnection;65;0;7;0
WireConnection;65;1;73;0
WireConnection;65;2;66;0
WireConnection;10;0;65;0
WireConnection;10;1;38;0
WireConnection;6;0;10;0
WireConnection;6;3;38;0
WireConnection;45;0;6;0
ASEEND*/
//CHKSM=99E0130E3ED89F2A6F87406CEF89FD23735F1783