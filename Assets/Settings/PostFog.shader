Shader "MC/PostEffect/PostFog"
{

    SubShader
    {
        ZTest Always Cull Off ZWrite Off

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

        TEXTURE2D_X(_PostFog_NoiseTex);
        SAMPLER(sampler_PostFog_NoiseTex);
        TEXTURE2D_X_FLOAT(_CameraTransparentDepthTexture);
        SAMPLER(sampler_CameraTransparentDepthTexture);

        float4 _SourceSize;

        float4 _PostFog_Params;
        float4 _PostFog_Ranges;

        half4 _PostFog_StartColor;
        half4 _PostFog_EndColor;

        float4x4 _PostFog_FrustumsRay;
        float2 _WorldSpaceUpDirToScreen;

        #define _FogStart _PostFog_Ranges.x
        #define _FogEnd _PostFog_Ranges.y
        #define _FogDensity _PostFog_Ranges.z

        #define _FogXSpeed _PostFog_Params.x
        #define _FogYSpeed _PostFog_Params.y
        #define _NoiseAmount _PostFog_Params.z
        #define _SkyDensity _PostFog_Params.w

        float4 _PlayerPos;

        float ComputeFogDistance(float depth)
        {
            float dist = depth;
            dist -= _ProjectionParams.y;
            return dist;
        }

        half ComputeFog(float z)
        {
            half fog;
            #if FOG_LINEAR
			fog = z * unity_FogParams.z + unity_FogParams.w;
            #elif FOG_EXP
			fog = exp2(-unity_FogParams.y * z);
            #else // FOG_EXP2
            fog = unity_FogParams.x * z;
            fog = exp2(-fog * fog);
            #endif
            return saturate(fog);
        }

        half4 Fragment(Varyings input) : SV_Target
        {
            // 要计算用于采样深度缓冲区的 UV 坐标，
            // 请将像素位置除以渲染目标分辨率
            // _ScaledScreenParams。
            float2 UV = input.positionCS.xy / _ScaledScreenParams.xy;

            // 从摄像机深度纹理中采样深度。
            #if UNITY_REVERSED_Z
            float depth = SampleSceneDepth(UV);
            #else
                    //  调整 Z 以匹配 OpenGL 的 NDC ([-1, 1])
                    float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
            #endif

            // 重建世界空间位置。
            float3 positionWS = ComputeWorldSpacePosition(UV, depth, UNITY_MATRIX_I_VP);

            float cameraDist = distance(_WorldSpaceCameraPos, positionWS);

            float dist = cameraDist - _ProjectionParams.y; //减去近截面
            half distFog = 1 - ComputeFog(dist);

            half2 speed = _Time.y * float2(_FogXSpeed, _FogYSpeed);
            half noise = (SAMPLE_TEXTURE2D_X(_PostFog_NoiseTex, sampler_PostFog_NoiseTex, input.texcoord.xy + speed).r - 0.5) * _NoiseAmount;

            float heightFog = (_FogEnd - positionWS.y) / (_FogEnd - _FogStart);
            float t = heightFog;
            heightFog = heightFog / 2;
            heightFog = saturate(heightFog * _FogDensity * (1 + noise));

            half fog = max(distFog, heightFog);
            // fog = distFog;
            fog = heightFog;
            // 天空盒---开始，使用_SkyDensity乘以fog
            #if UNITY_REVERSED_Z
            // 具有 REVERSED_Z 的平台（如 D3D）的情况。
            fog *= lerp(1, _SkyDensity, depth < 0.0001);
            #else
                    fog *= lerp(1, _SkyDensity, depth > 0.9999);
            #endif
            // 天空盒---结束

            half4 finalColor = lerp(_PostFog_StartColor, _PostFog_EndColor, t);
            finalColor.a = fog;

            half4 sourceColor = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, input.texcoord.xy);

            return finalColor * finalColor.a + (1 - finalColor.a) * sourceColor;
        }
        ENDHLSL

        Pass
        {
            Tags
            {
                "RenderPipeline" = "UniversalPipeline"
            }
            HLSLPROGRAM
            // #pragma enable_d3d11_debug_symbols
            #pragma vertex Vert
            #pragma fragment Fragment
            #pragma multi_compile_fog
            ENDHLSL
        }

    }
}