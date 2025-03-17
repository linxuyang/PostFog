// 此 Unity 着色器使用深度纹理和屏幕空间 UV 坐标来重建
//像素的世界空间位置。该着色器在网格上绘制棋盘图案，
//使位置可视化。
Shader "Example/URPReconstructWorldPos"
{
    Properties {}

    // 包含 Shader 代码的 SubShader 代码块。
    SubShader
    {
        // SubShader Tags 定义何时以及在何种条件下执行某个 SubShader 代码块
        // 或某个通道。
        Tags
        {
            "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Pass
        {
            HLSLPROGRAM
            // 此行定义顶点着色器的名称。
            #pragma vertex vert
            // 此行定义片元着色器的名称。
            #pragma fragment frag

            // Core.hlsl 文件包含常用的 HLSL 宏和
            // 函数的定义，还包含对其他 HLSL 文件（例如
            // Common.hlsl、SpaceTransforms.hlsl 等）的#include 引用。
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // DeclareDepthTexture.hlsl 文件包含用于对摄像机深度纹理进行采样的
            // 实用程序。
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            // 此示例使用 Attributes 结构作为顶点着色器中的
            // 输入结构。
            struct Attributes
            {
                // positionOS 变量包含对象空间中的顶点
                // 位置。
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                // 此结构中的位置必须具有 SV_POSITION 语义。
                float4 positionHCS : SV_POSITION;
            };

            // 顶点着色器定义具有在 Varyings 结构中定义的
            // 属性。vert 函数的类型必须与它返回的类型（结构）
            // 匹配。
            Varyings vert(Attributes IN)
            {
                // 使用 Varyings 结构声明输出对象 (OUT)。
                Varyings OUT;
                // TransformObjectToHClip 函数将顶点位置
                // 从对象空间变换到齐次裁剪空间。
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // 返回输出。
                return OUT;
            }

            // 片元着色器定义。
            // Varyings 输入结构包含来自顶点着色器的
            // 插值。片元着色器使用 `Varyings` 结构中的
            // `positionHCS` 属性来获取像素的位置。
            half4 frag(Varyings IN) : SV_Target
            {
                // 要计算用于采样深度缓冲区的 UV 坐标，
                // 请将像素位置除以渲染目标分辨率
                // _ScaledScreenParams。
                float2 UV = IN.positionHCS.xy / _ScaledScreenParams.xy;

                // 从摄像机深度纹理中采样深度。
                #if UNITY_REVERSED_Z
                real depth = SampleSceneDepth(UV);
                #else
                    //  调整 Z 以匹配 OpenGL 的 NDC ([-1, 1])
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
                #endif

                // 重建世界空间位置。
                float3 worldPos = ComputeWorldSpacePosition(UV, depth, UNITY_MATRIX_I_VP);

                // 在远裁剪面附近将颜色设置为
                // 黑色。
                #if UNITY_REVERSED_Z
                // 具有 REVERSED_Z 的平台（如 D3D）的情况。
                if (depth < 0.0001)
                    return half4(worldPos.x, 0, 0, 1);
                    // return half4(worldPos.y, 0, 0, 1);
                    // return half4(worldPos.z, 0, 0, 1);
                #else
                    // 没有 REVERSED_Z 的平台（如 OpenGL）的情况。
                    if(depth > 0.9999)
                        return half4(0,0,0,1);
                #endif

                half alpha = saturate(worldPos.y * 0.3);
                // return half4(1, 0, 0, alpha);
                return half4(worldPos, 1);
            }
            ENDHLSL
        }
    }
}