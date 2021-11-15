// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PilotLightTrail"
{
	Properties
	{
		_TimeScale("Time Scale", Float) = 1.2
		[HDR]_FlameBase("Flame Base", Color) = (0.7169812,0,0.1262589,0)
		[HDR]_FlameTip("Flame Tip", Color) = (1,0.6629182,0,0)
		_MaskTexture("Mask Texture", 2D) = "white" {}
		_MaskStrength("Mask Strength", Range( 0 , 10)) = 0
		_BorderMaskStrength("Border Mask Strength", Range( 0 , 20)) = 4
		_BiasStrength("Bias Strength", Float) = 0.3
		_Noise1("Noise 1", 2D) = "white" {}
		_Noise1Tiling("Noise 1 Tiling", Vector) = (1,1,0,0)
		_Noise2Tiling("Noise 2 Tiling", Vector) = (1,1,0,0)
		_Noise2("Noise 2", 2D) = "white" {}
		_DistortionNoise("Distortion Noise", 2D) = "white" {}
		_DistortionTiling("Distortion Tiling", Vector) = (1,1,0,0)
		_DistortionStrength("Distortion Strength", Range( 0 , 10)) = 0.9
		_DissolveSpeed("Dissolve Speed", Vector) = (0,0,0,0)
		_TipStep("Tip Step", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform float4 _FlameBase;
		uniform float4 _FlameTip;
		uniform sampler2D _MaskTexture;
		uniform float _TimeScale;
		uniform sampler2D _DistortionNoise;
		uniform float2 _DistortionTiling;
		uniform float _DistortionStrength;
		uniform sampler2D _Noise1;
		uniform float2 _Noise1Tiling;
		uniform sampler2D _Noise2;
		uniform float2 _Noise2Tiling;
		uniform float _BiasStrength;
		uniform float _MaskStrength;
		uniform float2 _DissolveSpeed;
		uniform float _BorderMaskStrength;
		uniform float _TipStep;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float mulTime4 = _Time.y * _TimeScale;
			float Time5 = mulTime4;
			float2 uv_TexCoord77 = i.uv_texcoord * _DistortionTiling;
			float2 panner75 = ( Time5 * float2( 0.4,0 ) + uv_TexCoord77);
			float4 UV2 = ( float4( i.uv_texcoord, 0.0 , 0.0 ) + ( tex2D( _DistortionNoise, panner75 ) * _DistortionStrength ) );
			float2 panner6 = ( Time5 * float2( 1,0 ) + ( UV2 * float4( _Noise1Tiling, 0.0 , 0.0 ) ).rg);
			float2 panner59 = ( Time5 * float2( 1,0 ) + ( UV2 * float4( _Noise2Tiling, 0.0 , 0.0 ) ).rg);
			float2 appendResult9 = (float2(tex2D( _Noise1, panner6 ).r , tex2D( _Noise2, panner59 ).r));
			float U14 = ( 1.0 - i.uv_texcoord.x );
			float2 panner19 = ( Time5 * float2( 0,0 ) + ( UV2 + float4( ( ( ( appendResult9 + -0.5 ) * 2.0 ) * _BiasStrength * U14 ), 0.0 , 0.0 ) ).rg);
			float2 panner25 = ( Time5 * _DissolveSpeed + UV2.rg);
			float clampResult31 = clamp( ( ( ( 1.0 - U14 ) + -0.55 ) * 2.0 ) , 0.25 , 0.75 );
			float4 temp_cast_10 = (( U14 * 0.9 )).xxxx;
			float4 temp_cast_11 = (0.0).xxxx;
			float4 temp_cast_12 = (1.0).xxxx;
			float4 clampResult33 = clamp( ( ( tex2D( _Noise2, panner25 ) + clampResult31 ) - temp_cast_10 ) , temp_cast_11 , temp_cast_12 );
			float Mask41 = saturate( ( i.uv_texcoord.y * ( 1.0 - i.uv_texcoord.y ) * U14 * _BorderMaskStrength ) );
			float4 temp_output_42_0 = ( ( tex2D( _MaskTexture, panner19 ) * _MaskStrength ) * clampResult33 * Mask41 * i.vertexColor.a );
			float4 temp_cast_13 = (_TipStep).xxxx;
			float4 lerpResult88 = lerp( _FlameTip , _FlameBase , saturate( step( temp_output_42_0 , temp_cast_13 ) ));
			float4 lerpResult46 = lerp( _FlameBase , lerpResult88 , saturate( ( U14 * 4.0 ) ));
			float4 temp_output_100_0 = saturate( temp_output_42_0 );
			o.Emission = ( lerpResult46 * temp_output_100_0 ).rgb;
			o.Alpha = temp_output_100_0.r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.vertexColor = IN.color;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18921
1282;73;1344;1022;876.6018;1502.285;1.514082;True;False
Node;AmplifyShaderEditor.RangedFloatNode;3;-3347.676,986.3561;Inherit;False;Property;_TimeScale;Time Scale;0;0;Create;True;0;0;0;False;0;False;1.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;4;-3196.675,987.3561;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;82;-4380.372,626.5176;Inherit;False;Property;_DistortionTiling;Distortion Tiling;13;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-3013.595,985.3561;Inherit;False;Time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-4045.62,577.4055;Inherit;False;5;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;-4215.809,428.6778;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;75;-3869.622,449.4063;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.4,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;74;-3645.622,417.4059;Inherit;True;Property;_DistortionNoise;Distortion Noise;12;0;Create;True;0;0;0;False;0;False;-1;7340c99f6b627e348a293b7c52264e98;7340c99f6b627e348a293b7c52264e98;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;81;-3632,640;Inherit;False;Property;_DistortionStrength;Distortion Strength;14;0;Create;True;0;0;0;False;0;False;0.9;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-3451.675,824.3562;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-3308.857,425.515;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-3143.988,818.9861;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;2;-2981.56,816.0064;Inherit;False;UV;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;61;-2629.162,430.0232;Inherit;False;Property;_Noise1Tiling;Noise 1 Tiling;9;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;63;-2605.881,891.1049;Inherit;False;Property;_Noise2Tiling;Noise 2 Tiling;10;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-2401.425,816.8453;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2439.612,381.1073;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;67;-2278.728,107.1038;Inherit;True;Property;_Noise2;Noise 2;11;0;Create;True;0;0;0;False;0;False;69af364942ff886459b15ac4acf12f00;69af364942ff886459b15ac4acf12f00;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;6;-2268.05,375.7356;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;59;-2261.016,802.2337;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;83;-3144.779,1436.656;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-2913.249,1503.62;Inherit;False;U;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;68;-2053.861,759.5991;Inherit;True;Property;_TextureSample1;Texture Sample 1;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-2066.108,519.6782;Inherit;True;Property;_Noise1;Noise 1;8;0;Create;True;0;0;0;False;0;False;-1;faa1d2cf5dd834f4aa79ca0e14008434;022104b5ac3b9e4419e61d04b021d330;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;22;-2093.222,-324.9913;Inherit;False;14;U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;9;-1731.885,639.6257;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-2062.003,10.0823;Inherit;False;5;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;27;-1650.023,60.24217;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;69;-2238.753,-117.0758;Inherit;False;Property;_DissolveSpeed;Dissolve Speed;15;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FunctionNode;10;-1560.117,622.3788;Inherit;False;ConstantBiasScale;-1;;3;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT2;0,0;False;1;FLOAT;-0.5;False;2;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-2351.869,-252.2965;Inherit;False;2;UV;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1525.222,763.8892;Inherit;False;Property;_BiasStrength;Bias Strength;7;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-1521.636,855.5671;Inherit;False;14;U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;30;-1482.371,66.0069;Inherit;False;ConstantBiasScale;-1;;4;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT;0;False;1;FLOAT;-0.55;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;25;-1817.756,-147.7056;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-1283.436,654.5876;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;35;-2494.078,1411.074;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-2514.282,1675.804;Inherit;False;Property;_BorderMaskStrength;Border Mask Strength;6;0;Create;True;0;0;0;False;0;False;4;12;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-1280.636,562.5673;Inherit;False;2;UV;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-2252.282,1373.171;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-1053.636,649.5671;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;65;-1575.279,-214.5442;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;69af364942ff886459b15ac4acf12f00;022104b5ac3b9e4419e61d04b021d330;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;31;-1266.371,60.0069;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;0.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-1053.636,780.5671;Inherit;False;5;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1073.606,-307.4731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;94;-1978.988,1418.262;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-1146.371,-41.9931;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;19;-779.636,648.5671;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-1562.282,1388.171;Inherit;False;Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;32;-881.3997,-151.1851;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;21;-581.203,436.8287;Inherit;True;Property;_MaskTexture;Mask Texture;4;0;Create;True;0;0;0;False;0;False;-1;341d462ceec27437fadefd380d61eef2;341d462ceec27437fadefd380d61eef2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;58;-785.2074,47.15594;Inherit;False;Constant;_Float2;Float 2;11;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-946.2943,-21.52456;Inherit;False;Constant;_Float3;Float 3;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-438.5473,765.2585;Inherit;False;Property;_MaskStrength;Mask Strength;5;0;Create;True;0;0;0;False;0;False;0;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;33;-638.6849,-152.8008;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-590.9265,85.47691;Inherit;False;41;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-224.1524,484.5367;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;44;-435.0353,-636.1786;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-80.56076,51.23843;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-96.01648,-324.9535;Inherit;False;Property;_TipStep;Tip Step;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;208.7851,-574.2966;Inherit;False;14;U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;91;47.9458,-394.63;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;398.8818,-557.3558;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;47;27.79935,-1084.87;Inherit;False;Property;_FlameBase;Flame Base;1;1;[HDR];Create;True;0;0;0;False;0;False;0.7169812,0,0.1262589,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;98;338.5472,-323.5104;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;48;-390.2784,-873.5028;Inherit;False;Property;_FlameTip;Flame Tip;2;1;[HDR];Create;True;0;0;0;False;0;False;1,0.6629182,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;97;586.8489,-548.0632;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;88;308.1988,-770.4281;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;46;511.0854,-853.1179;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;100;277.1287,43.5927;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;801.2311,-337.347;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-177.0177,-496.7972;Inherit;False;Property;_Emission;Emission;3;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-37.99691,-662.8088;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1180.737,-333.1395;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;PilotLightTrail;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;3;0
WireConnection;5;0;4;0
WireConnection;77;0;82;0
WireConnection;75;0;77;0
WireConnection;75;1;76;0
WireConnection;74;1;75;0
WireConnection;80;0;74;0
WireConnection;80;1;81;0
WireConnection;79;0;1;0
WireConnection;79;1;80;0
WireConnection;2;0;79;0
WireConnection;64;0;2;0
WireConnection;64;1;63;0
WireConnection;60;0;2;0
WireConnection;60;1;61;0
WireConnection;6;0;60;0
WireConnection;6;1;5;0
WireConnection;59;0;64;0
WireConnection;59;1;5;0
WireConnection;83;0;1;1
WireConnection;14;0;83;0
WireConnection;68;0;67;0
WireConnection;68;1;59;0
WireConnection;7;1;6;0
WireConnection;9;0;7;0
WireConnection;9;1;68;0
WireConnection;27;0;22;0
WireConnection;10;3;9;0
WireConnection;30;3;27;0
WireConnection;25;0;24;0
WireConnection;25;2;69;0
WireConnection;25;1;26;0
WireConnection;11;0;10;0
WireConnection;11;1;12;0
WireConnection;11;2;16;0
WireConnection;35;0;1;2
WireConnection;37;0;1;2
WireConnection;37;1;35;0
WireConnection;37;2;14;0
WireConnection;37;3;38;0
WireConnection;18;0;17;0
WireConnection;18;1;11;0
WireConnection;65;0;67;0
WireConnection;65;1;25;0
WireConnection;31;0;30;0
WireConnection;23;0;22;0
WireConnection;94;0;37;0
WireConnection;29;0;65;0
WireConnection;29;1;31;0
WireConnection;19;0;18;0
WireConnection;19;1;20;0
WireConnection;41;0;94;0
WireConnection;32;0;29;0
WireConnection;32;1;23;0
WireConnection;21;1;19;0
WireConnection;33;0;32;0
WireConnection;33;1;57;0
WireConnection;33;2;58;0
WireConnection;84;0;21;0
WireConnection;84;1;85;0
WireConnection;42;0;84;0
WireConnection;42;1;33;0
WireConnection;42;2;43;0
WireConnection;42;3;44;4
WireConnection;91;0;42;0
WireConnection;91;1;92;0
WireConnection;96;0;49;0
WireConnection;98;0;91;0
WireConnection;97;0;96;0
WireConnection;88;0;48;0
WireConnection;88;1;47;0
WireConnection;88;2;98;0
WireConnection;46;0;47;0
WireConnection;46;1;88;0
WireConnection;46;2;97;0
WireConnection;100;0;42;0
WireConnection;53;0;46;0
WireConnection;53;1;100;0
WireConnection;45;0;44;0
WireConnection;45;1;52;0
WireConnection;0;2;53;0
WireConnection;0;9;100;0
ASEEND*/
//CHKSM=6E8CDEAC317BFBD3D9DA3031559B7252F75F2C46