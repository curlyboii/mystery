Shader "Mystory/See through"
{
    Properties
    {
        _Position("Player Position", Vector) = (0.5, 0.5, 0, 0)
        _Size("Size", Float) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Opacity("Opacity", Range(0, 1)) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        [HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
        [HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
    }
        SubShader
        {
            Tags
            {
                "RenderPipeline" = "UniversalPipeline"
                "RenderType" = "Transparent"
                "UniversalMaterialType" = "Lit"
                "Queue" = "Transparent"
                "ShaderGraphShader" = "true"
                "ShaderGraphTargetId" = "UniversalLitSubTarget"
            }
            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }

            // Render State
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _CLUSTERED_RENDERING
            // GraphKeywords: <None>

            // Defines

            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SHADOW_COORD
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            #define _FOG_FRAGMENT 1
            #define _SURFACE_TYPE_TRANSPARENT 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv1 : TEXCOORD1;
                 float4 uv2 : TEXCOORD2;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 tangentWS;
                 float3 viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                 float2 staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                 float2 dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                 float3 sh;
                #endif
                 float4 fogFactorAndVertexLight;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                 float4 shadowCoord;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float3 TangentSpaceNormal;
                 float3 WorldSpacePosition;
                 float4 ScreenPosition;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float3 interp1 : INTERP1;
                 float4 interp2 : INTERP2;
                 float3 interp3 : INTERP3;
                 float2 interp4 : INTERP4;
                 float2 interp5 : INTERP5;
                 float3 interp6 : INTERP6;
                 float4 interp7 : INTERP7;
                 float4 interp8 : INTERP8;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz = input.positionWS;
                output.interp1.xyz = input.normalWS;
                output.interp2.xyzw = input.tangentWS;
                output.interp3.xyz = input.viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                output.interp4.xy = input.staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                output.interp5.xy = input.dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.interp6.xyz = input.sh;
                #endif
                output.interp7.xyzw = input.fogFactorAndVertexLight;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                output.interp8.xyzw = input.shadowCoord;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                output.normalWS = input.interp1.xyz;
                output.tangentWS = input.interp2.xyzw;
                output.viewDirectionWS = input.interp3.xyz;
                #if defined(LIGHTMAP_ON)
                output.staticLightmapUV = input.interp4.xy;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                output.dynamicLightmapUV = input.interp5.xy;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.interp6.xyz;
                #endif
                output.fogFactorAndVertexLight = input.interp7.xyzw;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                output.shadowCoord = input.interp8.xyzw;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }


            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float2 _Position;
            float _Size;
            float _Smoothness;
            float _Opacity;
            CBUFFER_END

                // Object and Global properties

                // Graph Includes
                // GraphIncludes: <None>

                // -- Property used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A + B;
            }

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }

            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }

            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A - B;
            }

            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A / B;
            }

            void Unity_Length_float2(float2 In, out float Out)
            {
                Out = length(In);
            }

            void Unity_OneMinus_float(float In, out float Out)
            {
                Out = 1 - In;
            }

            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }

            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = 0;
                surface.Smoothness = 0;
                surface.Occlusion = 0;
                surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif





                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }

                // Render State
                Cull Back
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag

                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _LIGHT_LAYERS
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SHADOW_COORD
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
                #define _SURFACE_TYPE_TRANSPARENT 1
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float3 interp3 : INTERP3;
                     float2 interp4 : INTERP4;
                     float2 interp5 : INTERP5;
                     float3 interp6 : INTERP6;
                     float4 interp7 : INTERP7;
                     float4 interp8 : INTERP8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
                    output.interp2.xyzw = input.tangentWS;
                    output.interp3.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp4.xy = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp5.xy = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz = input.sh;
                    #endif
                    output.interp7.xyzw = input.fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.interp8.xyzw = input.shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.viewDirectionWS = input.interp3.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp4.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.interp8.xyzw;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float2 _Position;
                float _Size;
                float _Smoothness;
                float _Opacity;
                CBUFFER_END

                    // Object and Global properties

                    // Graph Includes
                    // GraphIncludes: <None>

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                // -- Properties used by SceneSelectionPass
                #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
                #endif

                // Graph Functions

                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }

                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }

                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }

                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A * B;
                }

                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A - B;
                }

                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }

                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }

                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A / B;
                }

                void Unity_Length_float2(float2 In, out float Out)
                {
                    Out = length(In);
                }

                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }

                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }

                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }

                // Custom interpolators pre vertex
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };

                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }

                // Custom interpolators, pre surface
                #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                #endif

                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                    float Alpha;
                };

                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                    float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                    float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                    float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                    Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                    float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                    Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                    float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                    Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                    float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                    Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                    float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                    Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                    float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                    float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                    float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                    Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                    float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                    float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                    Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                    float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                    Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                    float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                    Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                    float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                    Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                    float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                    Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                    float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                    float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                    Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                    float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                    Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                    surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                    surface.NormalTS = IN.TangentSpaceNormal;
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = 0;
                    surface.Smoothness = 0;
                    surface.Occlusion = 0;
                    surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                    return surface;
                }

                // --------------------------------------------------
                // Build Graph Inputs
                #ifdef HAVE_VFX_MODIFICATION
                #define VFX_SRP_ATTRIBUTES Attributes
                #define VFX_SRP_VARYINGS Varyings
                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                #endif
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                    output.ObjectSpaceNormal = input.normalOS;
                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                    output.ObjectSpacePosition = input.positionOS;

                    return output;
                }
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                #endif





                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                        return output;
                }

                // --------------------------------------------------
                // Main

                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

                // --------------------------------------------------
                // Visual Effect Vertex Invocations
                #ifdef HAVE_VFX_MODIFICATION
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                #endif

                ENDHLSL
                }
                Pass
                {
                    Name "ShadowCaster"
                    Tags
                    {
                        "LightMode" = "ShadowCaster"
                    }

                    // Render State
                    Cull Back
                    ZTest LEqual
                    ZWrite On
                    ColorMask 0

                    // Debug
                    // <None>

                    // --------------------------------------------------
                    // Pass

                    HLSLPROGRAM

                    // Pragmas
                    #pragma target 4.5
                    #pragma exclude_renderers gles gles3 glcore
                    #pragma multi_compile_instancing
                    #pragma multi_compile _ DOTS_INSTANCING_ON
                    #pragma vertex vert
                    #pragma fragment frag

                    // DotsInstancingOptions: <None>
                    // HybridV1InjectedBuiltinProperties: <None>

                    // Keywords
                    #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                    // GraphKeywords: <None>

                    // Defines

                    #define _NORMALMAP 1
                    #define _NORMAL_DROPOFF_TS 1
                    #define ATTRIBUTES_NEED_NORMAL
                    #define ATTRIBUTES_NEED_TANGENT
                    #define VARYINGS_NEED_POSITION_WS
                    #define VARYINGS_NEED_NORMAL_WS
                    #define FEATURES_GRAPH_VERTEX
                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                    #define SHADERPASS SHADERPASS_SHADOWCASTER
                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                    // custom interpolator pre-include
                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                    // Includes
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                    // --------------------------------------------------
                    // Structs and Packing

                    // custom interpolators pre packing
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                    struct Attributes
                    {
                         float3 positionOS : POSITION;
                         float3 normalOS : NORMAL;
                         float4 tangentOS : TANGENT;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : INSTANCEID_SEMANTIC;
                        #endif
                    };
                    struct Varyings
                    {
                         float4 positionCS : SV_POSITION;
                         float3 positionWS;
                         float3 normalWS;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };
                    struct SurfaceDescriptionInputs
                    {
                         float3 WorldSpacePosition;
                         float4 ScreenPosition;
                    };
                    struct VertexDescriptionInputs
                    {
                         float3 ObjectSpaceNormal;
                         float3 ObjectSpaceTangent;
                         float3 ObjectSpacePosition;
                    };
                    struct PackedVaryings
                    {
                         float4 positionCS : SV_POSITION;
                         float3 interp0 : INTERP0;
                         float3 interp1 : INTERP1;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };

                    PackedVaryings PackVaryings(Varyings input)
                    {
                        PackedVaryings output;
                        ZERO_INITIALIZE(PackedVaryings, output);
                        output.positionCS = input.positionCS;
                        output.interp0.xyz = input.positionWS;
                        output.interp1.xyz = input.normalWS;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }

                    Varyings UnpackVaryings(PackedVaryings input)
                    {
                        Varyings output;
                        output.positionCS = input.positionCS;
                        output.positionWS = input.interp0.xyz;
                        output.normalWS = input.interp1.xyz;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }


                    // --------------------------------------------------
                    // Graph

                    // Graph Properties
                    CBUFFER_START(UnityPerMaterial)
                    float2 _Position;
                    float _Size;
                    float _Smoothness;
                    float _Opacity;
                    CBUFFER_END

                        // Object and Global properties

                        // Graph Includes
                        // GraphIncludes: <None>

                        // -- Property used by ScenePickingPass
                        #ifdef SCENEPICKINGPASS
                        float4 _SelectionID;
                        #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                    {
                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                    }

                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }

                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A - B;
                    }

                    void Unity_Divide_float(float A, float B, out float Out)
                    {
                        Out = A / B;
                    }

                    void Unity_Multiply_float_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A / B;
                    }

                    void Unity_Length_float2(float2 In, out float Out)
                    {
                        Out = length(In);
                    }

                    void Unity_OneMinus_float(float In, out float Out)
                    {
                        Out = 1 - In;
                    }

                    void Unity_Saturate_float(float In, out float Out)
                    {
                        Out = saturate(In);
                    }

                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                    {
                        Out = smoothstep(Edge1, Edge2, In);
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        description.Position = IN.ObjectSpacePosition;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float Alpha;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                        float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                        float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                        float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                        Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                        float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                        Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                        float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                        Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                        float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                        Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                        float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                        Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                        float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                        float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                        float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                        Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                        float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                        float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                        Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                        float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                        Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                        float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                        Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                        float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                        Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                        float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                        Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                        float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                        float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                        Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                        float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                        Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                        surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif







                        output.WorldSpacePosition = input.positionWS;
                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "DepthNormals"
                        Tags
                        {
                            "LightMode" = "DepthNormals"
                        }

                        // Render State
                        Cull Back
                        ZTest LEqual
                        ZWrite On

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 4.5
                        #pragma exclude_renderers gles gles3 glcore
                        #pragma multi_compile_instancing
                        #pragma multi_compile _ DOTS_INSTANCING_ON
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        // PassKeywords: <None>
                        // GraphKeywords: <None>

                        // Defines

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD1
                        #define VARYINGS_NEED_POSITION_WS
                        #define VARYINGS_NEED_NORMAL_WS
                        #define VARYINGS_NEED_TANGENT_WS
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                             float4 uv1 : TEXCOORD1;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 positionWS;
                             float3 normalWS;
                             float4 tangentWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                             float3 TangentSpaceNormal;
                             float3 WorldSpacePosition;
                             float4 ScreenPosition;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 interp0 : INTERP0;
                             float3 interp1 : INTERP1;
                             float4 interp2 : INTERP2;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.interp0.xyz = input.positionWS;
                            output.interp1.xyz = input.normalWS;
                            output.interp2.xyzw = input.tangentWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.positionWS = input.interp0.xyz;
                            output.normalWS = input.interp1.xyz;
                            output.tangentWS = input.interp2.xyzw;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float2 _Position;
                        float _Size;
                        float _Smoothness;
                        float _Opacity;
                        CBUFFER_END

                            // Object and Global properties

                            // Graph Includes
                            // GraphIncludes: <None>

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                        // -- Properties used by SceneSelectionPass
                        #ifdef SCENESELECTIONPASS
                        int _ObjectId;
                        int _PassValue;
                        #endif

                        // Graph Functions

                        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                        {
                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                        }

                        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A + B;
                        }

                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                        {
                            Out = UV * Tiling + Offset;
                        }

                        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A - B;
                        }

                        void Unity_Divide_float(float A, float B, out float Out)
                        {
                            Out = A / B;
                        }

                        void Unity_Multiply_float_float(float A, float B, out float Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A / B;
                        }

                        void Unity_Length_float2(float2 In, out float Out)
                        {
                            Out = length(In);
                        }

                        void Unity_OneMinus_float(float In, out float Out)
                        {
                            Out = 1 - In;
                        }

                        void Unity_Saturate_float(float In, out float Out)
                        {
                            Out = saturate(In);
                        }

                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                        {
                            Out = smoothstep(Edge1, Edge2, In);
                        }

                        // Custom interpolators pre vertex
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                        // Graph Vertex
                        struct VertexDescription
                        {
                            float3 Position;
                            float3 Normal;
                            float3 Tangent;
                        };

                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                        {
                            VertexDescription description = (VertexDescription)0;
                            description.Position = IN.ObjectSpacePosition;
                            description.Normal = IN.ObjectSpaceNormal;
                            description.Tangent = IN.ObjectSpaceTangent;
                            return description;
                        }

                        // Custom interpolators, pre surface
                        #ifdef FEATURES_GRAPH_VERTEX
                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                        {
                        return output;
                        }
                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                        #endif

                        // Graph Pixel
                        struct SurfaceDescription
                        {
                            float3 NormalTS;
                            float Alpha;
                        };

                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                        {
                            SurfaceDescription surface = (SurfaceDescription)0;
                            float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                            float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                            float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                            float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                            Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                            float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                            Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                            float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                            Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                            float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                            Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                            float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                            Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                            float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                            float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                            float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                            Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                            float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                            float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                            Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                            float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                            Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                            float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                            Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                            float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                            Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                            float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                            Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                            float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                            float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                            Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                            float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                            Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                            surface.NormalTS = IN.TangentSpaceNormal;
                            surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                            return surface;
                        }

                        // --------------------------------------------------
                        // Build Graph Inputs
                        #ifdef HAVE_VFX_MODIFICATION
                        #define VFX_SRP_ATTRIBUTES Attributes
                        #define VFX_SRP_VARYINGS Varyings
                        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                        #endif
                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                        {
                            VertexDescriptionInputs output;
                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                            output.ObjectSpaceNormal = input.normalOS;
                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                            output.ObjectSpacePosition = input.positionOS;

                            return output;
                        }
                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                        {
                            SurfaceDescriptionInputs output;
                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                        #ifdef HAVE_VFX_MODIFICATION
                            // FragInputs from VFX come from two places: Interpolator or CBuffer.
                            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                        #endif





                            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                            output.WorldSpacePosition = input.positionWS;
                            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                        #else
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                        #endif
                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                return output;
                        }

                        // --------------------------------------------------
                        // Main

                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                        // --------------------------------------------------
                        // Visual Effect Vertex Invocations
                        #ifdef HAVE_VFX_MODIFICATION
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                        #endif

                        ENDHLSL
                        }
                        Pass
                        {
                            Name "Meta"
                            Tags
                            {
                                "LightMode" = "Meta"
                            }

                            // Render State
                            Cull Off

                            // Debug
                            // <None>

                            // --------------------------------------------------
                            // Pass

                            HLSLPROGRAM

                            // Pragmas
                            #pragma target 4.5
                            #pragma exclude_renderers gles gles3 glcore
                            #pragma vertex vert
                            #pragma fragment frag

                            // DotsInstancingOptions: <None>
                            // HybridV1InjectedBuiltinProperties: <None>

                            // Keywords
                            #pragma shader_feature _ EDITOR_VISUALIZATION
                            // GraphKeywords: <None>

                            // Defines

                            #define _NORMALMAP 1
                            #define _NORMAL_DROPOFF_TS 1
                            #define ATTRIBUTES_NEED_NORMAL
                            #define ATTRIBUTES_NEED_TANGENT
                            #define ATTRIBUTES_NEED_TEXCOORD0
                            #define ATTRIBUTES_NEED_TEXCOORD1
                            #define ATTRIBUTES_NEED_TEXCOORD2
                            #define VARYINGS_NEED_POSITION_WS
                            #define VARYINGS_NEED_TEXCOORD0
                            #define VARYINGS_NEED_TEXCOORD1
                            #define VARYINGS_NEED_TEXCOORD2
                            #define FEATURES_GRAPH_VERTEX
                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                            #define SHADERPASS SHADERPASS_META
                            #define _FOG_FRAGMENT 1
                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                            // custom interpolator pre-include
                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                            // Includes
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                            // --------------------------------------------------
                            // Structs and Packing

                            // custom interpolators pre packing
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                            struct Attributes
                            {
                                 float3 positionOS : POSITION;
                                 float3 normalOS : NORMAL;
                                 float4 tangentOS : TANGENT;
                                 float4 uv0 : TEXCOORD0;
                                 float4 uv1 : TEXCOORD1;
                                 float4 uv2 : TEXCOORD2;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : INSTANCEID_SEMANTIC;
                                #endif
                            };
                            struct Varyings
                            {
                                 float4 positionCS : SV_POSITION;
                                 float3 positionWS;
                                 float4 texCoord0;
                                 float4 texCoord1;
                                 float4 texCoord2;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };
                            struct SurfaceDescriptionInputs
                            {
                                 float3 WorldSpacePosition;
                                 float4 ScreenPosition;
                            };
                            struct VertexDescriptionInputs
                            {
                                 float3 ObjectSpaceNormal;
                                 float3 ObjectSpaceTangent;
                                 float3 ObjectSpacePosition;
                            };
                            struct PackedVaryings
                            {
                                 float4 positionCS : SV_POSITION;
                                 float3 interp0 : INTERP0;
                                 float4 interp1 : INTERP1;
                                 float4 interp2 : INTERP2;
                                 float4 interp3 : INTERP3;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };

                            PackedVaryings PackVaryings(Varyings input)
                            {
                                PackedVaryings output;
                                ZERO_INITIALIZE(PackedVaryings, output);
                                output.positionCS = input.positionCS;
                                output.interp0.xyz = input.positionWS;
                                output.interp1.xyzw = input.texCoord0;
                                output.interp2.xyzw = input.texCoord1;
                                output.interp3.xyzw = input.texCoord2;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }

                            Varyings UnpackVaryings(PackedVaryings input)
                            {
                                Varyings output;
                                output.positionCS = input.positionCS;
                                output.positionWS = input.interp0.xyz;
                                output.texCoord0 = input.interp1.xyzw;
                                output.texCoord1 = input.interp2.xyzw;
                                output.texCoord2 = input.interp3.xyzw;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }


                            // --------------------------------------------------
                            // Graph

                            // Graph Properties
                            CBUFFER_START(UnityPerMaterial)
                            float2 _Position;
                            float _Size;
                            float _Smoothness;
                            float _Opacity;
                            CBUFFER_END

                                // Object and Global properties

                                // Graph Includes
                                // GraphIncludes: <None>

                                // -- Property used by ScenePickingPass
                                #ifdef SCENEPICKINGPASS
                                float4 _SelectionID;
                                #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions

                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                            {
                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                            }

                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                            {
                                Out = A + B;
                            }

                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                            {
                                Out = UV * Tiling + Offset;
                            }

                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                            {
                                Out = A - B;
                            }

                            void Unity_Divide_float(float A, float B, out float Out)
                            {
                                Out = A / B;
                            }

                            void Unity_Multiply_float_float(float A, float B, out float Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                            {
                                Out = A / B;
                            }

                            void Unity_Length_float2(float2 In, out float Out)
                            {
                                Out = length(In);
                            }

                            void Unity_OneMinus_float(float In, out float Out)
                            {
                                Out = 1 - In;
                            }

                            void Unity_Saturate_float(float In, out float Out)
                            {
                                Out = saturate(In);
                            }

                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                            {
                                Out = smoothstep(Edge1, Edge2, In);
                            }

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                description.Position = IN.ObjectSpacePosition;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float3 BaseColor;
                                float3 Emission;
                                float Alpha;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                                surface.Emission = float3(0, 0, 0);
                                surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif







                                output.WorldSpacePosition = input.positionWS;
                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "SceneSelectionPass"
                                Tags
                                {
                                    "LightMode" = "SceneSelectionPass"
                                }

                                // Render State
                                Cull Off

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 4.5
                                #pragma exclude_renderers gles gles3 glcore
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define VARYINGS_NEED_POSITION_WS
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                #define SCENESELECTIONPASS 1
                                #define ALPHA_CLIP_THRESHOLD 1
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 positionWS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                     float3 WorldSpacePosition;
                                     float4 ScreenPosition;
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 interp0 : INTERP0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    output.interp0.xyz = input.positionWS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    output.positionWS = input.interp0.xyz;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float2 _Position;
                                float _Size;
                                float _Smoothness;
                                float _Opacity;
                                CBUFFER_END

                                    // Object and Global properties

                                    // Graph Includes
                                    // GraphIncludes: <None>

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                // -- Properties used by SceneSelectionPass
                                #ifdef SCENESELECTIONPASS
                                int _ObjectId;
                                int _PassValue;
                                #endif

                                // Graph Functions

                                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                {
                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                }

                                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A + B;
                                }

                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                {
                                    Out = UV * Tiling + Offset;
                                }

                                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A - B;
                                }

                                void Unity_Divide_float(float A, float B, out float Out)
                                {
                                    Out = A / B;
                                }

                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A / B;
                                }

                                void Unity_Length_float2(float2 In, out float Out)
                                {
                                    Out = length(In);
                                }

                                void Unity_OneMinus_float(float In, out float Out)
                                {
                                    Out = 1 - In;
                                }

                                void Unity_Saturate_float(float In, out float Out)
                                {
                                    Out = saturate(In);
                                }

                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                {
                                    Out = smoothstep(Edge1, Edge2, In);
                                }

                                // Custom interpolators pre vertex
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                // Graph Vertex
                                struct VertexDescription
                                {
                                    float3 Position;
                                    float3 Normal;
                                    float3 Tangent;
                                };

                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                {
                                    VertexDescription description = (VertexDescription)0;
                                    description.Position = IN.ObjectSpacePosition;
                                    description.Normal = IN.ObjectSpaceNormal;
                                    description.Tangent = IN.ObjectSpaceTangent;
                                    return description;
                                }

                                // Custom interpolators, pre surface
                                #ifdef FEATURES_GRAPH_VERTEX
                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                {
                                return output;
                                }
                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                #endif

                                // Graph Pixel
                                struct SurfaceDescription
                                {
                                    float Alpha;
                                };

                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                {
                                    SurfaceDescription surface = (SurfaceDescription)0;
                                    float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                    float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                    float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                    float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                    Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                    float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                    Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                    float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                    Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                    float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                    Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                    float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                    Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                    float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                    float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                    float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                    Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                    float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                    float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                    Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                    float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                    Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                    float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                    Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                    float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                    Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                    float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                    Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                    float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                    float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                    Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                    float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                    Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                    surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                    return surface;
                                }

                                // --------------------------------------------------
                                // Build Graph Inputs
                                #ifdef HAVE_VFX_MODIFICATION
                                #define VFX_SRP_ATTRIBUTES Attributes
                                #define VFX_SRP_VARYINGS Varyings
                                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                #endif
                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                {
                                    VertexDescriptionInputs output;
                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                    output.ObjectSpaceNormal = input.normalOS;
                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                    output.ObjectSpacePosition = input.positionOS;

                                    return output;
                                }
                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                {
                                    SurfaceDescriptionInputs output;
                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                #ifdef HAVE_VFX_MODIFICATION
                                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                #endif







                                    output.WorldSpacePosition = input.positionWS;
                                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                #else
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                #endif
                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                        return output;
                                }

                                // --------------------------------------------------
                                // Main

                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                // --------------------------------------------------
                                // Visual Effect Vertex Invocations
                                #ifdef HAVE_VFX_MODIFICATION
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                #endif

                                ENDHLSL
                                }
                                Pass
                                {
                                    Name "ScenePickingPass"
                                    Tags
                                    {
                                        "LightMode" = "Picking"
                                    }

                                    // Render State
                                    Cull Back

                                    // Debug
                                    // <None>

                                    // --------------------------------------------------
                                    // Pass

                                    HLSLPROGRAM

                                    // Pragmas
                                    #pragma target 4.5
                                    #pragma exclude_renderers gles gles3 glcore
                                    #pragma vertex vert
                                    #pragma fragment frag

                                    // DotsInstancingOptions: <None>
                                    // HybridV1InjectedBuiltinProperties: <None>

                                    // Keywords
                                    // PassKeywords: <None>
                                    // GraphKeywords: <None>

                                    // Defines

                                    #define _NORMALMAP 1
                                    #define _NORMAL_DROPOFF_TS 1
                                    #define ATTRIBUTES_NEED_NORMAL
                                    #define ATTRIBUTES_NEED_TANGENT
                                    #define VARYINGS_NEED_POSITION_WS
                                    #define FEATURES_GRAPH_VERTEX
                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                    #define SHADERPASS SHADERPASS_DEPTHONLY
                                    #define SCENEPICKINGPASS 1
                                    #define ALPHA_CLIP_THRESHOLD 1
                                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                    // custom interpolator pre-include
                                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                    // Includes
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                    // --------------------------------------------------
                                    // Structs and Packing

                                    // custom interpolators pre packing
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                    struct Attributes
                                    {
                                         float3 positionOS : POSITION;
                                         float3 normalOS : NORMAL;
                                         float4 tangentOS : TANGENT;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                         uint instanceID : INSTANCEID_SEMANTIC;
                                        #endif
                                    };
                                    struct Varyings
                                    {
                                         float4 positionCS : SV_POSITION;
                                         float3 positionWS;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                        #endif
                                    };
                                    struct SurfaceDescriptionInputs
                                    {
                                         float3 WorldSpacePosition;
                                         float4 ScreenPosition;
                                    };
                                    struct VertexDescriptionInputs
                                    {
                                         float3 ObjectSpaceNormal;
                                         float3 ObjectSpaceTangent;
                                         float3 ObjectSpacePosition;
                                    };
                                    struct PackedVaryings
                                    {
                                         float4 positionCS : SV_POSITION;
                                         float3 interp0 : INTERP0;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                        #endif
                                    };

                                    PackedVaryings PackVaryings(Varyings input)
                                    {
                                        PackedVaryings output;
                                        ZERO_INITIALIZE(PackedVaryings, output);
                                        output.positionCS = input.positionCS;
                                        output.interp0.xyz = input.positionWS;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        output.instanceID = input.instanceID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        output.cullFace = input.cullFace;
                                        #endif
                                        return output;
                                    }

                                    Varyings UnpackVaryings(PackedVaryings input)
                                    {
                                        Varyings output;
                                        output.positionCS = input.positionCS;
                                        output.positionWS = input.interp0.xyz;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        output.instanceID = input.instanceID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        output.cullFace = input.cullFace;
                                        #endif
                                        return output;
                                    }


                                    // --------------------------------------------------
                                    // Graph

                                    // Graph Properties
                                    CBUFFER_START(UnityPerMaterial)
                                    float2 _Position;
                                    float _Size;
                                    float _Smoothness;
                                    float _Opacity;
                                    CBUFFER_END

                                        // Object and Global properties

                                        // Graph Includes
                                        // GraphIncludes: <None>

                                        // -- Property used by ScenePickingPass
                                        #ifdef SCENEPICKINGPASS
                                        float4 _SelectionID;
                                        #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions

                                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                    {
                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                    }

                                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                    {
                                        Out = UV * Tiling + Offset;
                                    }

                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A - B;
                                    }

                                    void Unity_Divide_float(float A, float B, out float Out)
                                    {
                                        Out = A / B;
                                    }

                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A / B;
                                    }

                                    void Unity_Length_float2(float2 In, out float Out)
                                    {
                                        Out = length(In);
                                    }

                                    void Unity_OneMinus_float(float In, out float Out)
                                    {
                                        Out = 1 - In;
                                    }

                                    void Unity_Saturate_float(float In, out float Out)
                                    {
                                        Out = saturate(In);
                                    }

                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                    {
                                        Out = smoothstep(Edge1, Edge2, In);
                                    }

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        description.Position = IN.ObjectSpacePosition;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                        float Alpha;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                        float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                        float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                        float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                        Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                        float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                        Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                        float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                        Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                        float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                        Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                        float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                        Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                        float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                        float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                        float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                        Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                        float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                        float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                        Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                        float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                        Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                        float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                        Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                        float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                        Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                        float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                        Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                        float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                        float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                        Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                        float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                        Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                        surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.ObjectSpacePosition = input.positionOS;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif







                                        output.WorldSpacePosition = input.positionWS;
                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                    }

                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
                                    Pass
                                    {
                                        // Name: <None>
                                        Tags
                                        {
                                            "LightMode" = "Universal2D"
                                        }

                                        // Render State
                                        Cull Back
                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                        ZTest LEqual
                                        ZWrite Off

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 4.5
                                        #pragma exclude_renderers gles gles3 glcore
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // DotsInstancingOptions: <None>
                                        // HybridV1InjectedBuiltinProperties: <None>

                                        // Keywords
                                        // PassKeywords: <None>
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define VARYINGS_NEED_POSITION_WS
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_2D
                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 positionWS;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                             float3 WorldSpacePosition;
                                             float4 ScreenPosition;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 interp0 : INTERP0;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.interp0.xyz = input.positionWS;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.positionWS = input.interp0.xyz;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float2 _Position;
                                        float _Size;
                                        float _Smoothness;
                                        float _Opacity;
                                        CBUFFER_END

                                            // Object and Global properties

                                            // Graph Includes
                                            // GraphIncludes: <None>

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                        // -- Properties used by SceneSelectionPass
                                        #ifdef SCENESELECTIONPASS
                                        int _ObjectId;
                                        int _PassValue;
                                        #endif

                                        // Graph Functions

                                        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                        {
                                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                        }

                                        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A + B;
                                        }

                                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                        {
                                            Out = UV * Tiling + Offset;
                                        }

                                        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A * B;
                                        }

                                        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A - B;
                                        }

                                        void Unity_Divide_float(float A, float B, out float Out)
                                        {
                                            Out = A / B;
                                        }

                                        void Unity_Multiply_float_float(float A, float B, out float Out)
                                        {
                                            Out = A * B;
                                        }

                                        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A / B;
                                        }

                                        void Unity_Length_float2(float2 In, out float Out)
                                        {
                                            Out = length(In);
                                        }

                                        void Unity_OneMinus_float(float In, out float Out)
                                        {
                                            Out = 1 - In;
                                        }

                                        void Unity_Saturate_float(float In, out float Out)
                                        {
                                            Out = saturate(In);
                                        }

                                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                        {
                                            Out = smoothstep(Edge1, Edge2, In);
                                        }

                                        // Custom interpolators pre vertex
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                        // Graph Vertex
                                        struct VertexDescription
                                        {
                                            float3 Position;
                                            float3 Normal;
                                            float3 Tangent;
                                        };

                                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                        {
                                            VertexDescription description = (VertexDescription)0;
                                            description.Position = IN.ObjectSpacePosition;
                                            description.Normal = IN.ObjectSpaceNormal;
                                            description.Tangent = IN.ObjectSpaceTangent;
                                            return description;
                                        }

                                        // Custom interpolators, pre surface
                                        #ifdef FEATURES_GRAPH_VERTEX
                                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                        {
                                        return output;
                                        }
                                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                        #endif

                                        // Graph Pixel
                                        struct SurfaceDescription
                                        {
                                            float3 BaseColor;
                                            float Alpha;
                                        };

                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                        {
                                            SurfaceDescription surface = (SurfaceDescription)0;
                                            float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                            float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                            float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                            float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                            Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                            float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                            Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                            float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                            Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                            float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                            Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                            float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                            Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                            float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                            float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                            float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                            Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                            float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                            float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                            Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                            float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                            Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                            float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                            Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                            float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                            Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                            float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                            Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                            float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                            float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                            Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                            float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                            Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                                            surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                            return surface;
                                        }

                                        // --------------------------------------------------
                                        // Build Graph Inputs
                                        #ifdef HAVE_VFX_MODIFICATION
                                        #define VFX_SRP_ATTRIBUTES Attributes
                                        #define VFX_SRP_VARYINGS Varyings
                                        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                        #endif
                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                        {
                                            VertexDescriptionInputs output;
                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                            output.ObjectSpaceNormal = input.normalOS;
                                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                                            output.ObjectSpacePosition = input.positionOS;

                                            return output;
                                        }
                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                        {
                                            SurfaceDescriptionInputs output;
                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                        #ifdef HAVE_VFX_MODIFICATION
                                            // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                        #endif







                                            output.WorldSpacePosition = input.positionWS;
                                            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                        #else
                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                        #endif
                                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                return output;
                                        }

                                        // --------------------------------------------------
                                        // Main

                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                        // --------------------------------------------------
                                        // Visual Effect Vertex Invocations
                                        #ifdef HAVE_VFX_MODIFICATION
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                        #endif

                                        ENDHLSL
                                        }
        }
            SubShader
                                        {
                                            Tags
                                            {
                                                "RenderPipeline" = "UniversalPipeline"
                                                "RenderType" = "Transparent"
                                                "UniversalMaterialType" = "Lit"
                                                "Queue" = "Transparent"
                                                "ShaderGraphShader" = "true"
                                                "ShaderGraphTargetId" = "UniversalLitSubTarget"
                                            }
                                            Pass
                                            {
                                                Name "Universal Forward"
                                                Tags
                                                {
                                                    "LightMode" = "UniversalForward"
                                                }

                                            // Render State
                                            Cull Back
                                            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                            ZTest LEqual
                                            ZWrite Off

                                            // Debug
                                            // <None>

                                            // --------------------------------------------------
                                            // Pass

                                            HLSLPROGRAM

                                            // Pragmas
                                            #pragma target 2.0
                                            #pragma only_renderers gles gles3 glcore d3d11
                                            #pragma multi_compile_instancing
                                            #pragma multi_compile_fog
                                            #pragma instancing_options renderinglayer
                                            #pragma vertex vert
                                            #pragma fragment frag

                                            // DotsInstancingOptions: <None>
                                            // HybridV1InjectedBuiltinProperties: <None>

                                            // Keywords
                                            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
                                            #pragma multi_compile _ LIGHTMAP_ON
                                            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                                            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                                            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
                                            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                                            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                                            #pragma multi_compile_fragment _ _SHADOWS_SOFT
                                            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                            #pragma multi_compile _ SHADOWS_SHADOWMASK
                                            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                                            #pragma multi_compile_fragment _ _LIGHT_LAYERS
                                            #pragma multi_compile_fragment _ DEBUG_DISPLAY
                                            #pragma multi_compile_fragment _ _LIGHT_COOKIES
                                            #pragma multi_compile _ _CLUSTERED_RENDERING
                                            // GraphKeywords: <None>

                                            // Defines

                                            #define _NORMALMAP 1
                                            #define _NORMAL_DROPOFF_TS 1
                                            #define ATTRIBUTES_NEED_NORMAL
                                            #define ATTRIBUTES_NEED_TANGENT
                                            #define ATTRIBUTES_NEED_TEXCOORD1
                                            #define ATTRIBUTES_NEED_TEXCOORD2
                                            #define VARYINGS_NEED_POSITION_WS
                                            #define VARYINGS_NEED_NORMAL_WS
                                            #define VARYINGS_NEED_TANGENT_WS
                                            #define VARYINGS_NEED_VIEWDIRECTION_WS
                                            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                            #define VARYINGS_NEED_SHADOW_COORD
                                            #define FEATURES_GRAPH_VERTEX
                                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                            #define SHADERPASS SHADERPASS_FORWARD
                                            #define _FOG_FRAGMENT 1
                                            #define _SURFACE_TYPE_TRANSPARENT 1
                                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                            // custom interpolator pre-include
                                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                            // Includes
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                            // --------------------------------------------------
                                            // Structs and Packing

                                            // custom interpolators pre packing
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                            struct Attributes
                                            {
                                                 float3 positionOS : POSITION;
                                                 float3 normalOS : NORMAL;
                                                 float4 tangentOS : TANGENT;
                                                 float4 uv1 : TEXCOORD1;
                                                 float4 uv2 : TEXCOORD2;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                 uint instanceID : INSTANCEID_SEMANTIC;
                                                #endif
                                            };
                                            struct Varyings
                                            {
                                                 float4 positionCS : SV_POSITION;
                                                 float3 positionWS;
                                                 float3 normalWS;
                                                 float4 tangentWS;
                                                 float3 viewDirectionWS;
                                                #if defined(LIGHTMAP_ON)
                                                 float2 staticLightmapUV;
                                                #endif
                                                #if defined(DYNAMICLIGHTMAP_ON)
                                                 float2 dynamicLightmapUV;
                                                #endif
                                                #if !defined(LIGHTMAP_ON)
                                                 float3 sh;
                                                #endif
                                                 float4 fogFactorAndVertexLight;
                                                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                 float4 shadowCoord;
                                                #endif
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                #endif
                                            };
                                            struct SurfaceDescriptionInputs
                                            {
                                                 float3 TangentSpaceNormal;
                                                 float3 WorldSpacePosition;
                                                 float4 ScreenPosition;
                                            };
                                            struct VertexDescriptionInputs
                                            {
                                                 float3 ObjectSpaceNormal;
                                                 float3 ObjectSpaceTangent;
                                                 float3 ObjectSpacePosition;
                                            };
                                            struct PackedVaryings
                                            {
                                                 float4 positionCS : SV_POSITION;
                                                 float3 interp0 : INTERP0;
                                                 float3 interp1 : INTERP1;
                                                 float4 interp2 : INTERP2;
                                                 float3 interp3 : INTERP3;
                                                 float2 interp4 : INTERP4;
                                                 float2 interp5 : INTERP5;
                                                 float3 interp6 : INTERP6;
                                                 float4 interp7 : INTERP7;
                                                 float4 interp8 : INTERP8;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                #endif
                                            };

                                            PackedVaryings PackVaryings(Varyings input)
                                            {
                                                PackedVaryings output;
                                                ZERO_INITIALIZE(PackedVaryings, output);
                                                output.positionCS = input.positionCS;
                                                output.interp0.xyz = input.positionWS;
                                                output.interp1.xyz = input.normalWS;
                                                output.interp2.xyzw = input.tangentWS;
                                                output.interp3.xyz = input.viewDirectionWS;
                                                #if defined(LIGHTMAP_ON)
                                                output.interp4.xy = input.staticLightmapUV;
                                                #endif
                                                #if defined(DYNAMICLIGHTMAP_ON)
                                                output.interp5.xy = input.dynamicLightmapUV;
                                                #endif
                                                #if !defined(LIGHTMAP_ON)
                                                output.interp6.xyz = input.sh;
                                                #endif
                                                output.interp7.xyzw = input.fogFactorAndVertexLight;
                                                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                output.interp8.xyzw = input.shadowCoord;
                                                #endif
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                output.instanceID = input.instanceID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                output.cullFace = input.cullFace;
                                                #endif
                                                return output;
                                            }

                                            Varyings UnpackVaryings(PackedVaryings input)
                                            {
                                                Varyings output;
                                                output.positionCS = input.positionCS;
                                                output.positionWS = input.interp0.xyz;
                                                output.normalWS = input.interp1.xyz;
                                                output.tangentWS = input.interp2.xyzw;
                                                output.viewDirectionWS = input.interp3.xyz;
                                                #if defined(LIGHTMAP_ON)
                                                output.staticLightmapUV = input.interp4.xy;
                                                #endif
                                                #if defined(DYNAMICLIGHTMAP_ON)
                                                output.dynamicLightmapUV = input.interp5.xy;
                                                #endif
                                                #if !defined(LIGHTMAP_ON)
                                                output.sh = input.interp6.xyz;
                                                #endif
                                                output.fogFactorAndVertexLight = input.interp7.xyzw;
                                                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                output.shadowCoord = input.interp8.xyzw;
                                                #endif
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                output.instanceID = input.instanceID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                output.cullFace = input.cullFace;
                                                #endif
                                                return output;
                                            }


                                            // --------------------------------------------------
                                            // Graph

                                            // Graph Properties
                                            CBUFFER_START(UnityPerMaterial)
                                            float2 _Position;
                                            float _Size;
                                            float _Smoothness;
                                            float _Opacity;
                                            CBUFFER_END

                                                // Object and Global properties

                                                // Graph Includes
                                                // GraphIncludes: <None>

                                                // -- Property used by ScenePickingPass
                                                #ifdef SCENEPICKINGPASS
                                                float4 _SelectionID;
                                                #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions

                                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                            {
                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                            }

                                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                            {
                                                Out = UV * Tiling + Offset;
                                            }

                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A - B;
                                            }

                                            void Unity_Divide_float(float A, float B, out float Out)
                                            {
                                                Out = A / B;
                                            }

                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A / B;
                                            }

                                            void Unity_Length_float2(float2 In, out float Out)
                                            {
                                                Out = length(In);
                                            }

                                            void Unity_OneMinus_float(float In, out float Out)
                                            {
                                                Out = 1 - In;
                                            }

                                            void Unity_Saturate_float(float In, out float Out)
                                            {
                                                Out = saturate(In);
                                            }

                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                            {
                                                Out = smoothstep(Edge1, Edge2, In);
                                            }

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                description.Position = IN.ObjectSpacePosition;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float3 BaseColor;
                                                float3 NormalTS;
                                                float3 Emission;
                                                float Metallic;
                                                float Smoothness;
                                                float Occlusion;
                                                float Alpha;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                surface.Emission = float3(0, 0, 0);
                                                surface.Metallic = 0;
                                                surface.Smoothness = 0;
                                                surface.Occlusion = 0;
                                                surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.ObjectSpacePosition = input.positionOS;

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif





                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                output.WorldSpacePosition = input.positionWS;
                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                            #else
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                            #endif
                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                    return output;
                                            }

                                            // --------------------------------------------------
                                            // Main

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
                                            Pass
                                            {
                                                Name "ShadowCaster"
                                                Tags
                                                {
                                                    "LightMode" = "ShadowCaster"
                                                }

                                                // Render State
                                                Cull Back
                                                ZTest LEqual
                                                ZWrite On
                                                ColorMask 0

                                                // Debug
                                                // <None>

                                                // --------------------------------------------------
                                                // Pass

                                                HLSLPROGRAM

                                                // Pragmas
                                                #pragma target 2.0
                                                #pragma only_renderers gles gles3 glcore d3d11
                                                #pragma multi_compile_instancing
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // DotsInstancingOptions: <None>
                                                // HybridV1InjectedBuiltinProperties: <None>

                                                // Keywords
                                                #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                                // GraphKeywords: <None>

                                                // Defines

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define VARYINGS_NEED_POSITION_WS
                                                #define VARYINGS_NEED_NORMAL_WS
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_SHADOWCASTER
                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                // custom interpolator pre-include
                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                // custom interpolators pre packing
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                struct Attributes
                                                {
                                                     float3 positionOS : POSITION;
                                                     float3 normalOS : NORMAL;
                                                     float4 tangentOS : TANGENT;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 positionWS;
                                                     float3 normalWS;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };
                                                struct SurfaceDescriptionInputs
                                                {
                                                     float3 WorldSpacePosition;
                                                     float4 ScreenPosition;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 ObjectSpacePosition;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 interp0 : INTERP0;
                                                     float3 interp1 : INTERP1;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                    output.positionCS = input.positionCS;
                                                    output.interp0.xyz = input.positionWS;
                                                    output.interp1.xyz = input.normalWS;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }

                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.positionWS = input.interp0.xyz;
                                                    output.normalWS = input.interp1.xyz;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }


                                                // --------------------------------------------------
                                                // Graph

                                                // Graph Properties
                                                CBUFFER_START(UnityPerMaterial)
                                                float2 _Position;
                                                float _Size;
                                                float _Smoothness;
                                                float _Opacity;
                                                CBUFFER_END

                                                    // Object and Global properties

                                                    // Graph Includes
                                                    // GraphIncludes: <None>

                                                    // -- Property used by ScenePickingPass
                                                    #ifdef SCENEPICKINGPASS
                                                    float4 _SelectionID;
                                                    #endif

                                                // -- Properties used by SceneSelectionPass
                                                #ifdef SCENESELECTIONPASS
                                                int _ObjectId;
                                                int _PassValue;
                                                #endif

                                                // Graph Functions

                                                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                {
                                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                }

                                                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A + B;
                                                }

                                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                {
                                                    Out = UV * Tiling + Offset;
                                                }

                                                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A * B;
                                                }

                                                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A - B;
                                                }

                                                void Unity_Divide_float(float A, float B, out float Out)
                                                {
                                                    Out = A / B;
                                                }

                                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                                {
                                                    Out = A * B;
                                                }

                                                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A / B;
                                                }

                                                void Unity_Length_float2(float2 In, out float Out)
                                                {
                                                    Out = length(In);
                                                }

                                                void Unity_OneMinus_float(float In, out float Out)
                                                {
                                                    Out = 1 - In;
                                                }

                                                void Unity_Saturate_float(float In, out float Out)
                                                {
                                                    Out = saturate(In);
                                                }

                                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                {
                                                    Out = smoothstep(Edge1, Edge2, In);
                                                }

                                                // Custom interpolators pre vertex
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                // Graph Vertex
                                                struct VertexDescription
                                                {
                                                    float3 Position;
                                                    float3 Normal;
                                                    float3 Tangent;
                                                };

                                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                {
                                                    VertexDescription description = (VertexDescription)0;
                                                    description.Position = IN.ObjectSpacePosition;
                                                    description.Normal = IN.ObjectSpaceNormal;
                                                    description.Tangent = IN.ObjectSpaceTangent;
                                                    return description;
                                                }

                                                // Custom interpolators, pre surface
                                                #ifdef FEATURES_GRAPH_VERTEX
                                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                {
                                                return output;
                                                }
                                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                #endif

                                                // Graph Pixel
                                                struct SurfaceDescription
                                                {
                                                    float Alpha;
                                                };

                                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                {
                                                    SurfaceDescription surface = (SurfaceDescription)0;
                                                    float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                    float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                    float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                    float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                    Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                    float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                    Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                    float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                    Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                    float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                    Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                    float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                    Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                    float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                    float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                    float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                    Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                    float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                    float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                    Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                    float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                    Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                    float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                    Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                    float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                    Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                    float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                    Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                    float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                    float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                    Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                    float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                    Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                    surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                    return surface;
                                                }

                                                // --------------------------------------------------
                                                // Build Graph Inputs
                                                #ifdef HAVE_VFX_MODIFICATION
                                                #define VFX_SRP_ATTRIBUTES Attributes
                                                #define VFX_SRP_VARYINGS Varyings
                                                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                #endif
                                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                {
                                                    VertexDescriptionInputs output;
                                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                    output.ObjectSpaceNormal = input.normalOS;
                                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                    output.ObjectSpacePosition = input.positionOS;

                                                    return output;
                                                }
                                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                {
                                                    SurfaceDescriptionInputs output;
                                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                #ifdef HAVE_VFX_MODIFICATION
                                                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                #endif







                                                    output.WorldSpacePosition = input.positionWS;
                                                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                #else
                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                #endif
                                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                        return output;
                                                }

                                                // --------------------------------------------------
                                                // Main

                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                                // --------------------------------------------------
                                                // Visual Effect Vertex Invocations
                                                #ifdef HAVE_VFX_MODIFICATION
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                #endif

                                                ENDHLSL
                                                }
                                                Pass
                                                {
                                                    Name "DepthNormals"
                                                    Tags
                                                    {
                                                        "LightMode" = "DepthNormals"
                                                    }

                                                    // Render State
                                                    Cull Back
                                                    ZTest LEqual
                                                    ZWrite On

                                                    // Debug
                                                    // <None>

                                                    // --------------------------------------------------
                                                    // Pass

                                                    HLSLPROGRAM

                                                    // Pragmas
                                                    #pragma target 2.0
                                                    #pragma only_renderers gles gles3 glcore d3d11
                                                    #pragma multi_compile_instancing
                                                    #pragma vertex vert
                                                    #pragma fragment frag

                                                    // DotsInstancingOptions: <None>
                                                    // HybridV1InjectedBuiltinProperties: <None>

                                                    // Keywords
                                                    // PassKeywords: <None>
                                                    // GraphKeywords: <None>

                                                    // Defines

                                                    #define _NORMALMAP 1
                                                    #define _NORMAL_DROPOFF_TS 1
                                                    #define ATTRIBUTES_NEED_NORMAL
                                                    #define ATTRIBUTES_NEED_TANGENT
                                                    #define ATTRIBUTES_NEED_TEXCOORD1
                                                    #define VARYINGS_NEED_POSITION_WS
                                                    #define VARYINGS_NEED_NORMAL_WS
                                                    #define VARYINGS_NEED_TANGENT_WS
                                                    #define FEATURES_GRAPH_VERTEX
                                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                    #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                    // custom interpolator pre-include
                                                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                    // Includes
                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Structs and Packing

                                                    // custom interpolators pre packing
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                    struct Attributes
                                                    {
                                                         float3 positionOS : POSITION;
                                                         float3 normalOS : NORMAL;
                                                         float4 tangentOS : TANGENT;
                                                         float4 uv1 : TEXCOORD1;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                         uint instanceID : INSTANCEID_SEMANTIC;
                                                        #endif
                                                    };
                                                    struct Varyings
                                                    {
                                                         float4 positionCS : SV_POSITION;
                                                         float3 positionWS;
                                                         float3 normalWS;
                                                         float4 tangentWS;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                        #endif
                                                    };
                                                    struct SurfaceDescriptionInputs
                                                    {
                                                         float3 TangentSpaceNormal;
                                                         float3 WorldSpacePosition;
                                                         float4 ScreenPosition;
                                                    };
                                                    struct VertexDescriptionInputs
                                                    {
                                                         float3 ObjectSpaceNormal;
                                                         float3 ObjectSpaceTangent;
                                                         float3 ObjectSpacePosition;
                                                    };
                                                    struct PackedVaryings
                                                    {
                                                         float4 positionCS : SV_POSITION;
                                                         float3 interp0 : INTERP0;
                                                         float3 interp1 : INTERP1;
                                                         float4 interp2 : INTERP2;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                        #endif
                                                    };

                                                    PackedVaryings PackVaryings(Varyings input)
                                                    {
                                                        PackedVaryings output;
                                                        ZERO_INITIALIZE(PackedVaryings, output);
                                                        output.positionCS = input.positionCS;
                                                        output.interp0.xyz = input.positionWS;
                                                        output.interp1.xyz = input.normalWS;
                                                        output.interp2.xyzw = input.tangentWS;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                        output.instanceID = input.instanceID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                        output.cullFace = input.cullFace;
                                                        #endif
                                                        return output;
                                                    }

                                                    Varyings UnpackVaryings(PackedVaryings input)
                                                    {
                                                        Varyings output;
                                                        output.positionCS = input.positionCS;
                                                        output.positionWS = input.interp0.xyz;
                                                        output.normalWS = input.interp1.xyz;
                                                        output.tangentWS = input.interp2.xyzw;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                        output.instanceID = input.instanceID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                        output.cullFace = input.cullFace;
                                                        #endif
                                                        return output;
                                                    }


                                                    // --------------------------------------------------
                                                    // Graph

                                                    // Graph Properties
                                                    CBUFFER_START(UnityPerMaterial)
                                                    float2 _Position;
                                                    float _Size;
                                                    float _Smoothness;
                                                    float _Opacity;
                                                    CBUFFER_END

                                                        // Object and Global properties

                                                        // Graph Includes
                                                        // GraphIncludes: <None>

                                                        // -- Property used by ScenePickingPass
                                                        #ifdef SCENEPICKINGPASS
                                                        float4 _SelectionID;
                                                        #endif

                                                    // -- Properties used by SceneSelectionPass
                                                    #ifdef SCENESELECTIONPASS
                                                    int _ObjectId;
                                                    int _PassValue;
                                                    #endif

                                                    // Graph Functions

                                                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                    {
                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                    }

                                                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                    {
                                                        Out = UV * Tiling + Offset;
                                                    }

                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A - B;
                                                    }

                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                    {
                                                        Out = A / B;
                                                    }

                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A / B;
                                                    }

                                                    void Unity_Length_float2(float2 In, out float Out)
                                                    {
                                                        Out = length(In);
                                                    }

                                                    void Unity_OneMinus_float(float In, out float Out)
                                                    {
                                                        Out = 1 - In;
                                                    }

                                                    void Unity_Saturate_float(float In, out float Out)
                                                    {
                                                        Out = saturate(In);
                                                    }

                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                    {
                                                        Out = smoothstep(Edge1, Edge2, In);
                                                    }

                                                    // Custom interpolators pre vertex
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                    // Graph Vertex
                                                    struct VertexDescription
                                                    {
                                                        float3 Position;
                                                        float3 Normal;
                                                        float3 Tangent;
                                                    };

                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                    {
                                                        VertexDescription description = (VertexDescription)0;
                                                        description.Position = IN.ObjectSpacePosition;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Custom interpolators, pre surface
                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                    {
                                                    return output;
                                                    }
                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                    #endif

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float3 NormalTS;
                                                        float Alpha;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                        float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                        float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                        float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                        Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                        float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                        Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                        float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                        Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                        float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                        Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                        float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                        Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                        float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                        float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                        float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                        Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                        float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                        float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                        Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                        float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                        Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                        float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                        Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                        float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                        Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                        float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                        Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                        float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                        float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                        Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                        float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                        Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                        surface.NormalTS = IN.TangentSpaceNormal;
                                                        surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                    #define VFX_SRP_VARYINGS Varyings
                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                    #endif
                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                        output.ObjectSpacePosition = input.positionOS;

                                                        return output;
                                                    }
                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                    #ifdef HAVE_VFX_MODIFICATION
                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                    #endif





                                                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                        output.WorldSpacePosition = input.positionWS;
                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                    #else
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                    #endif
                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                            return output;
                                                    }

                                                    // --------------------------------------------------
                                                    // Main

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Visual Effect Vertex Invocations
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                    #endif

                                                    ENDHLSL
                                                    }
                                                    Pass
                                                    {
                                                        Name "Meta"
                                                        Tags
                                                        {
                                                            "LightMode" = "Meta"
                                                        }

                                                        // Render State
                                                        Cull Off

                                                        // Debug
                                                        // <None>

                                                        // --------------------------------------------------
                                                        // Pass

                                                        HLSLPROGRAM

                                                        // Pragmas
                                                        #pragma target 2.0
                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        // DotsInstancingOptions: <None>
                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                        // Keywords
                                                        #pragma shader_feature _ EDITOR_VISUALIZATION
                                                        // GraphKeywords: <None>

                                                        // Defines

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                                        #define VARYINGS_NEED_POSITION_WS
                                                        #define VARYINGS_NEED_TEXCOORD0
                                                        #define VARYINGS_NEED_TEXCOORD1
                                                        #define VARYINGS_NEED_TEXCOORD2
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_META
                                                        #define _FOG_FRAGMENT 1
                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                        // custom interpolator pre-include
                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        // custom interpolators pre packing
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                        struct Attributes
                                                        {
                                                             float3 positionOS : POSITION;
                                                             float3 normalOS : NORMAL;
                                                             float4 tangentOS : TANGENT;
                                                             float4 uv0 : TEXCOORD0;
                                                             float4 uv1 : TEXCOORD1;
                                                             float4 uv2 : TEXCOORD2;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 positionWS;
                                                             float4 texCoord0;
                                                             float4 texCoord1;
                                                             float4 texCoord2;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct SurfaceDescriptionInputs
                                                        {
                                                             float3 WorldSpacePosition;
                                                             float4 ScreenPosition;
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 ObjectSpacePosition;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 interp0 : INTERP0;
                                                             float4 interp1 : INTERP1;
                                                             float4 interp2 : INTERP2;
                                                             float4 interp3 : INTERP3;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                            output.positionCS = input.positionCS;
                                                            output.interp0.xyz = input.positionWS;
                                                            output.interp1.xyzw = input.texCoord0;
                                                            output.interp2.xyzw = input.texCoord1;
                                                            output.interp3.xyzw = input.texCoord2;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }

                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            output.positionWS = input.interp0.xyz;
                                                            output.texCoord0 = input.interp1.xyzw;
                                                            output.texCoord1 = input.interp2.xyzw;
                                                            output.texCoord2 = input.interp3.xyzw;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }


                                                        // --------------------------------------------------
                                                        // Graph

                                                        // Graph Properties
                                                        CBUFFER_START(UnityPerMaterial)
                                                        float2 _Position;
                                                        float _Size;
                                                        float _Smoothness;
                                                        float _Opacity;
                                                        CBUFFER_END

                                                            // Object and Global properties

                                                            // Graph Includes
                                                            // GraphIncludes: <None>

                                                            // -- Property used by ScenePickingPass
                                                            #ifdef SCENEPICKINGPASS
                                                            float4 _SelectionID;
                                                            #endif

                                                        // -- Properties used by SceneSelectionPass
                                                        #ifdef SCENESELECTIONPASS
                                                        int _ObjectId;
                                                        int _PassValue;
                                                        #endif

                                                        // Graph Functions

                                                        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                        {
                                                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                        }

                                                        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                        {
                                                            Out = A + B;
                                                        }

                                                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                        {
                                                            Out = UV * Tiling + Offset;
                                                        }

                                                        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                        {
                                                            Out = A * B;
                                                        }

                                                        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                        {
                                                            Out = A - B;
                                                        }

                                                        void Unity_Divide_float(float A, float B, out float Out)
                                                        {
                                                            Out = A / B;
                                                        }

                                                        void Unity_Multiply_float_float(float A, float B, out float Out)
                                                        {
                                                            Out = A * B;
                                                        }

                                                        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                        {
                                                            Out = A / B;
                                                        }

                                                        void Unity_Length_float2(float2 In, out float Out)
                                                        {
                                                            Out = length(In);
                                                        }

                                                        void Unity_OneMinus_float(float In, out float Out)
                                                        {
                                                            Out = 1 - In;
                                                        }

                                                        void Unity_Saturate_float(float In, out float Out)
                                                        {
                                                            Out = saturate(In);
                                                        }

                                                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                        {
                                                            Out = smoothstep(Edge1, Edge2, In);
                                                        }

                                                        // Custom interpolators pre vertex
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                        // Graph Vertex
                                                        struct VertexDescription
                                                        {
                                                            float3 Position;
                                                            float3 Normal;
                                                            float3 Tangent;
                                                        };

                                                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                        {
                                                            VertexDescription description = (VertexDescription)0;
                                                            description.Position = IN.ObjectSpacePosition;
                                                            description.Normal = IN.ObjectSpaceNormal;
                                                            description.Tangent = IN.ObjectSpaceTangent;
                                                            return description;
                                                        }

                                                        // Custom interpolators, pre surface
                                                        #ifdef FEATURES_GRAPH_VERTEX
                                                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                        {
                                                        return output;
                                                        }
                                                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                        #endif

                                                        // Graph Pixel
                                                        struct SurfaceDescription
                                                        {
                                                            float3 BaseColor;
                                                            float3 Emission;
                                                            float Alpha;
                                                        };

                                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                        {
                                                            SurfaceDescription surface = (SurfaceDescription)0;
                                                            float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                            float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                            float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                            float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                            Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                            float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                            Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                            float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                            Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                            float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                            Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                            float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                            Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                            float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                            float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                            float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                            Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                            float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                            float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                            Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                            float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                            Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                            float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                            Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                            float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                            Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                            float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                            Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                            float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                            float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                            Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                            float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                            Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                                                            surface.Emission = float3(0, 0, 0);
                                                            surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                            return surface;
                                                        }

                                                        // --------------------------------------------------
                                                        // Build Graph Inputs
                                                        #ifdef HAVE_VFX_MODIFICATION
                                                        #define VFX_SRP_ATTRIBUTES Attributes
                                                        #define VFX_SRP_VARYINGS Varyings
                                                        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                        #endif
                                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                        {
                                                            VertexDescriptionInputs output;
                                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                            output.ObjectSpaceNormal = input.normalOS;
                                                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                            output.ObjectSpacePosition = input.positionOS;

                                                            return output;
                                                        }
                                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                        {
                                                            SurfaceDescriptionInputs output;
                                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                        #ifdef HAVE_VFX_MODIFICATION
                                                            // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                        #endif







                                                            output.WorldSpacePosition = input.positionWS;
                                                            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                        #else
                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                        #endif
                                                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                return output;
                                                        }

                                                        // --------------------------------------------------
                                                        // Main

                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Visual Effect Vertex Invocations
                                                        #ifdef HAVE_VFX_MODIFICATION
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                        #endif

                                                        ENDHLSL
                                                        }
                                                        Pass
                                                        {
                                                            Name "SceneSelectionPass"
                                                            Tags
                                                            {
                                                                "LightMode" = "SceneSelectionPass"
                                                            }

                                                            // Render State
                                                            Cull Off

                                                            // Debug
                                                            // <None>

                                                            // --------------------------------------------------
                                                            // Pass

                                                            HLSLPROGRAM

                                                            // Pragmas
                                                            #pragma target 2.0
                                                            #pragma only_renderers gles gles3 glcore d3d11
                                                            #pragma multi_compile_instancing
                                                            #pragma vertex vert
                                                            #pragma fragment frag

                                                            // DotsInstancingOptions: <None>
                                                            // HybridV1InjectedBuiltinProperties: <None>

                                                            // Keywords
                                                            // PassKeywords: <None>
                                                            // GraphKeywords: <None>

                                                            // Defines

                                                            #define _NORMALMAP 1
                                                            #define _NORMAL_DROPOFF_TS 1
                                                            #define ATTRIBUTES_NEED_NORMAL
                                                            #define ATTRIBUTES_NEED_TANGENT
                                                            #define VARYINGS_NEED_POSITION_WS
                                                            #define FEATURES_GRAPH_VERTEX
                                                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                            #define SHADERPASS SHADERPASS_DEPTHONLY
                                                            #define SCENESELECTIONPASS 1
                                                            #define ALPHA_CLIP_THRESHOLD 1
                                                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                            // custom interpolator pre-include
                                                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                            // Includes
                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Structs and Packing

                                                            // custom interpolators pre packing
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                            struct Attributes
                                                            {
                                                                 float3 positionOS : POSITION;
                                                                 float3 normalOS : NORMAL;
                                                                 float4 tangentOS : TANGENT;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                 uint instanceID : INSTANCEID_SEMANTIC;
                                                                #endif
                                                            };
                                                            struct Varyings
                                                            {
                                                                 float4 positionCS : SV_POSITION;
                                                                 float3 positionWS;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                #endif
                                                            };
                                                            struct SurfaceDescriptionInputs
                                                            {
                                                                 float3 WorldSpacePosition;
                                                                 float4 ScreenPosition;
                                                            };
                                                            struct VertexDescriptionInputs
                                                            {
                                                                 float3 ObjectSpaceNormal;
                                                                 float3 ObjectSpaceTangent;
                                                                 float3 ObjectSpacePosition;
                                                            };
                                                            struct PackedVaryings
                                                            {
                                                                 float4 positionCS : SV_POSITION;
                                                                 float3 interp0 : INTERP0;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                #endif
                                                            };

                                                            PackedVaryings PackVaryings(Varyings input)
                                                            {
                                                                PackedVaryings output;
                                                                ZERO_INITIALIZE(PackedVaryings, output);
                                                                output.positionCS = input.positionCS;
                                                                output.interp0.xyz = input.positionWS;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                output.instanceID = input.instanceID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                output.cullFace = input.cullFace;
                                                                #endif
                                                                return output;
                                                            }

                                                            Varyings UnpackVaryings(PackedVaryings input)
                                                            {
                                                                Varyings output;
                                                                output.positionCS = input.positionCS;
                                                                output.positionWS = input.interp0.xyz;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                output.instanceID = input.instanceID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                output.cullFace = input.cullFace;
                                                                #endif
                                                                return output;
                                                            }


                                                            // --------------------------------------------------
                                                            // Graph

                                                            // Graph Properties
                                                            CBUFFER_START(UnityPerMaterial)
                                                            float2 _Position;
                                                            float _Size;
                                                            float _Smoothness;
                                                            float _Opacity;
                                                            CBUFFER_END

                                                                // Object and Global properties

                                                                // Graph Includes
                                                                // GraphIncludes: <None>

                                                                // -- Property used by ScenePickingPass
                                                                #ifdef SCENEPICKINGPASS
                                                                float4 _SelectionID;
                                                                #endif

                                                            // -- Properties used by SceneSelectionPass
                                                            #ifdef SCENESELECTIONPASS
                                                            int _ObjectId;
                                                            int _PassValue;
                                                            #endif

                                                            // Graph Functions

                                                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                            {
                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                            }

                                                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                            {
                                                                Out = UV * Tiling + Offset;
                                                            }

                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A - B;
                                                            }

                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                            {
                                                                Out = A / B;
                                                            }

                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A / B;
                                                            }

                                                            void Unity_Length_float2(float2 In, out float Out)
                                                            {
                                                                Out = length(In);
                                                            }

                                                            void Unity_OneMinus_float(float In, out float Out)
                                                            {
                                                                Out = 1 - In;
                                                            }

                                                            void Unity_Saturate_float(float In, out float Out)
                                                            {
                                                                Out = saturate(In);
                                                            }

                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                            {
                                                                Out = smoothstep(Edge1, Edge2, In);
                                                            }

                                                            // Custom interpolators pre vertex
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                            // Graph Vertex
                                                            struct VertexDescription
                                                            {
                                                                float3 Position;
                                                                float3 Normal;
                                                                float3 Tangent;
                                                            };

                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                            {
                                                                VertexDescription description = (VertexDescription)0;
                                                                description.Position = IN.ObjectSpacePosition;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Custom interpolators, pre surface
                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                            {
                                                            return output;
                                                            }
                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                            #endif

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                                float Alpha;
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                                float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                                float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                                Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                                float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                                Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                                float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                                Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                                float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                                Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                                float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                                Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                                float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                                float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                                float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                                Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                                float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                                float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                                Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                                float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                                Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                                float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                                Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                                float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                                Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                                float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                                Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                                float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                                float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                                Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                                float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                                surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                            #define VFX_SRP_VARYINGS Varyings
                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                            #endif
                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                output.ObjectSpacePosition = input.positionOS;

                                                                return output;
                                                            }
                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                            #endif







                                                                output.WorldSpacePosition = input.positionWS;
                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                            #else
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                            #endif
                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                    return output;
                                                            }

                                                            // --------------------------------------------------
                                                            // Main

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Visual Effect Vertex Invocations
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                            #endif

                                                            ENDHLSL
                                                            }
                                                            Pass
                                                            {
                                                                Name "ScenePickingPass"
                                                                Tags
                                                                {
                                                                    "LightMode" = "Picking"
                                                                }

                                                                // Render State
                                                                Cull Back

                                                                // Debug
                                                                // <None>

                                                                // --------------------------------------------------
                                                                // Pass

                                                                HLSLPROGRAM

                                                                // Pragmas
                                                                #pragma target 2.0
                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                #pragma multi_compile_instancing
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // DotsInstancingOptions: <None>
                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                // Keywords
                                                                // PassKeywords: <None>
                                                                // GraphKeywords: <None>

                                                                // Defines

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define VARYINGS_NEED_POSITION_WS
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                #define SCENEPICKINGPASS 1
                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                // custom interpolators pre packing
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                struct Attributes
                                                                {
                                                                     float3 positionOS : POSITION;
                                                                     float3 normalOS : NORMAL;
                                                                     float4 tangentOS : TANGENT;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 positionWS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct SurfaceDescriptionInputs
                                                                {
                                                                     float3 WorldSpacePosition;
                                                                     float4 ScreenPosition;
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 ObjectSpacePosition;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 interp0 : INTERP0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                    output.positionCS = input.positionCS;
                                                                    output.interp0.xyz = input.positionWS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }

                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    output.positionWS = input.interp0.xyz;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }


                                                                // --------------------------------------------------
                                                                // Graph

                                                                // Graph Properties
                                                                CBUFFER_START(UnityPerMaterial)
                                                                float2 _Position;
                                                                float _Size;
                                                                float _Smoothness;
                                                                float _Opacity;
                                                                CBUFFER_END

                                                                    // Object and Global properties

                                                                    // Graph Includes
                                                                    // GraphIncludes: <None>

                                                                    // -- Property used by ScenePickingPass
                                                                    #ifdef SCENEPICKINGPASS
                                                                    float4 _SelectionID;
                                                                    #endif

                                                                // -- Properties used by SceneSelectionPass
                                                                #ifdef SCENESELECTIONPASS
                                                                int _ObjectId;
                                                                int _PassValue;
                                                                #endif

                                                                // Graph Functions

                                                                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                {
                                                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                }

                                                                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                {
                                                                    Out = A + B;
                                                                }

                                                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                {
                                                                    Out = UV * Tiling + Offset;
                                                                }

                                                                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                {
                                                                    Out = A * B;
                                                                }

                                                                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                {
                                                                    Out = A - B;
                                                                }

                                                                void Unity_Divide_float(float A, float B, out float Out)
                                                                {
                                                                    Out = A / B;
                                                                }

                                                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                {
                                                                    Out = A * B;
                                                                }

                                                                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                {
                                                                    Out = A / B;
                                                                }

                                                                void Unity_Length_float2(float2 In, out float Out)
                                                                {
                                                                    Out = length(In);
                                                                }

                                                                void Unity_OneMinus_float(float In, out float Out)
                                                                {
                                                                    Out = 1 - In;
                                                                }

                                                                void Unity_Saturate_float(float In, out float Out)
                                                                {
                                                                    Out = saturate(In);
                                                                }

                                                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                {
                                                                    Out = smoothstep(Edge1, Edge2, In);
                                                                }

                                                                // Custom interpolators pre vertex
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                // Graph Vertex
                                                                struct VertexDescription
                                                                {
                                                                    float3 Position;
                                                                    float3 Normal;
                                                                    float3 Tangent;
                                                                };

                                                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                {
                                                                    VertexDescription description = (VertexDescription)0;
                                                                    description.Position = IN.ObjectSpacePosition;
                                                                    description.Normal = IN.ObjectSpaceNormal;
                                                                    description.Tangent = IN.ObjectSpaceTangent;
                                                                    return description;
                                                                }

                                                                // Custom interpolators, pre surface
                                                                #ifdef FEATURES_GRAPH_VERTEX
                                                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                {
                                                                return output;
                                                                }
                                                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                #endif

                                                                // Graph Pixel
                                                                struct SurfaceDescription
                                                                {
                                                                    float Alpha;
                                                                };

                                                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                {
                                                                    SurfaceDescription surface = (SurfaceDescription)0;
                                                                    float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                                    float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                    float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                                    float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                                    Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                                    float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                                    Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                                    float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                                    Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                                    float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                                    Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                                    float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                                    Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                                    float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                                    float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                                    float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                                    Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                                    float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                                    float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                                    Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                                    float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                                    Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                                    float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                                    Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                                    float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                                    Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                                    float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                                    Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                                    float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                                    float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                                    Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                                    float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                    Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                                    surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                    return surface;
                                                                }

                                                                // --------------------------------------------------
                                                                // Build Graph Inputs
                                                                #ifdef HAVE_VFX_MODIFICATION
                                                                #define VFX_SRP_ATTRIBUTES Attributes
                                                                #define VFX_SRP_VARYINGS Varyings
                                                                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                #endif
                                                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                {
                                                                    VertexDescriptionInputs output;
                                                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                    output.ObjectSpaceNormal = input.normalOS;
                                                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                    output.ObjectSpacePosition = input.positionOS;

                                                                    return output;
                                                                }
                                                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                {
                                                                    SurfaceDescriptionInputs output;
                                                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                #ifdef HAVE_VFX_MODIFICATION
                                                                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                #endif







                                                                    output.WorldSpacePosition = input.positionWS;
                                                                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                #else
                                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                #endif
                                                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                        return output;
                                                                }

                                                                // --------------------------------------------------
                                                                // Main

                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Visual Effect Vertex Invocations
                                                                #ifdef HAVE_VFX_MODIFICATION
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                #endif

                                                                ENDHLSL
                                                                }
                                                                Pass
                                                                {
                                                                    // Name: <None>
                                                                    Tags
                                                                    {
                                                                        "LightMode" = "Universal2D"
                                                                    }

                                                                    // Render State
                                                                    Cull Back
                                                                    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                    ZTest LEqual
                                                                    ZWrite Off

                                                                    // Debug
                                                                    // <None>

                                                                    // --------------------------------------------------
                                                                    // Pass

                                                                    HLSLPROGRAM

                                                                    // Pragmas
                                                                    #pragma target 2.0
                                                                    #pragma only_renderers gles gles3 glcore d3d11
                                                                    #pragma multi_compile_instancing
                                                                    #pragma vertex vert
                                                                    #pragma fragment frag

                                                                    // DotsInstancingOptions: <None>
                                                                    // HybridV1InjectedBuiltinProperties: <None>

                                                                    // Keywords
                                                                    // PassKeywords: <None>
                                                                    // GraphKeywords: <None>

                                                                    // Defines

                                                                    #define _NORMALMAP 1
                                                                    #define _NORMAL_DROPOFF_TS 1
                                                                    #define ATTRIBUTES_NEED_NORMAL
                                                                    #define ATTRIBUTES_NEED_TANGENT
                                                                    #define VARYINGS_NEED_POSITION_WS
                                                                    #define FEATURES_GRAPH_VERTEX
                                                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                    #define SHADERPASS SHADERPASS_2D
                                                                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                    // custom interpolator pre-include
                                                                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                    // Includes
                                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Structs and Packing

                                                                    // custom interpolators pre packing
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                    struct Attributes
                                                                    {
                                                                         float3 positionOS : POSITION;
                                                                         float3 normalOS : NORMAL;
                                                                         float4 tangentOS : TANGENT;
                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                         uint instanceID : INSTANCEID_SEMANTIC;
                                                                        #endif
                                                                    };
                                                                    struct Varyings
                                                                    {
                                                                         float4 positionCS : SV_POSITION;
                                                                         float3 positionWS;
                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                        #endif
                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                        #endif
                                                                    };
                                                                    struct SurfaceDescriptionInputs
                                                                    {
                                                                         float3 WorldSpacePosition;
                                                                         float4 ScreenPosition;
                                                                    };
                                                                    struct VertexDescriptionInputs
                                                                    {
                                                                         float3 ObjectSpaceNormal;
                                                                         float3 ObjectSpaceTangent;
                                                                         float3 ObjectSpacePosition;
                                                                    };
                                                                    struct PackedVaryings
                                                                    {
                                                                         float4 positionCS : SV_POSITION;
                                                                         float3 interp0 : INTERP0;
                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                        #endif
                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                        #endif
                                                                    };

                                                                    PackedVaryings PackVaryings(Varyings input)
                                                                    {
                                                                        PackedVaryings output;
                                                                        ZERO_INITIALIZE(PackedVaryings, output);
                                                                        output.positionCS = input.positionCS;
                                                                        output.interp0.xyz = input.positionWS;
                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                        output.instanceID = input.instanceID;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                        #endif
                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                        output.cullFace = input.cullFace;
                                                                        #endif
                                                                        return output;
                                                                    }

                                                                    Varyings UnpackVaryings(PackedVaryings input)
                                                                    {
                                                                        Varyings output;
                                                                        output.positionCS = input.positionCS;
                                                                        output.positionWS = input.interp0.xyz;
                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                        output.instanceID = input.instanceID;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                        #endif
                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                        output.cullFace = input.cullFace;
                                                                        #endif
                                                                        return output;
                                                                    }


                                                                    // --------------------------------------------------
                                                                    // Graph

                                                                    // Graph Properties
                                                                    CBUFFER_START(UnityPerMaterial)
                                                                    float2 _Position;
                                                                    float _Size;
                                                                    float _Smoothness;
                                                                    float _Opacity;
                                                                    CBUFFER_END

                                                                        // Object and Global properties

                                                                        // Graph Includes
                                                                        // GraphIncludes: <None>

                                                                        // -- Property used by ScenePickingPass
                                                                        #ifdef SCENEPICKINGPASS
                                                                        float4 _SelectionID;
                                                                        #endif

                                                                    // -- Properties used by SceneSelectionPass
                                                                    #ifdef SCENESELECTIONPASS
                                                                    int _ObjectId;
                                                                    int _PassValue;
                                                                    #endif

                                                                    // Graph Functions

                                                                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                    {
                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                    }

                                                                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                    {
                                                                        Out = UV * Tiling + Offset;
                                                                    }

                                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A - B;
                                                                    }

                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A / B;
                                                                    }

                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A / B;
                                                                    }

                                                                    void Unity_Length_float2(float2 In, out float Out)
                                                                    {
                                                                        Out = length(In);
                                                                    }

                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                    {
                                                                        Out = 1 - In;
                                                                    }

                                                                    void Unity_Saturate_float(float In, out float Out)
                                                                    {
                                                                        Out = saturate(In);
                                                                    }

                                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                    {
                                                                        Out = smoothstep(Edge1, Edge2, In);
                                                                    }

                                                                    // Custom interpolators pre vertex
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                    // Graph Vertex
                                                                    struct VertexDescription
                                                                    {
                                                                        float3 Position;
                                                                        float3 Normal;
                                                                        float3 Tangent;
                                                                    };

                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                    {
                                                                        VertexDescription description = (VertexDescription)0;
                                                                        description.Position = IN.ObjectSpacePosition;
                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                        return description;
                                                                    }

                                                                    // Custom interpolators, pre surface
                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                    {
                                                                    return output;
                                                                    }
                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                    #endif

                                                                    // Graph Pixel
                                                                    struct SurfaceDescription
                                                                    {
                                                                        float3 BaseColor;
                                                                        float Alpha;
                                                                    };

                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                    {
                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                        float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                                        float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                        float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                                        float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                                        Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                                        float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                                        Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                                        float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                                        Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                                        float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                                        Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                                        float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                                        Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                                        float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                                        float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                                        float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                                        Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                                        float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                                        float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                                        Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                                        float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                                        Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                                        float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                                        Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                                        float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                                        Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                                        float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                                        Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                                        float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                                        float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                                        Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                                        float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                        Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                                        surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                                                                        surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                        return surface;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Build Graph Inputs
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                    #endif
                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                    {
                                                                        VertexDescriptionInputs output;
                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                        return output;
                                                                    }
                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                    #endif







                                                                        output.WorldSpacePosition = input.positionWS;
                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                    #else
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                    #endif
                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                            return output;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Main

                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Visual Effect Vertex Invocations
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                    #endif

                                                                    ENDHLSL
                                                                    }
                                        }
                                            CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                        SubShader
                                                                    {
                                                                        Tags
                                                                        {
                                                                            // RenderPipeline: <None>
                                                                            "RenderType" = "Transparent"
                                                                            "BuiltInMaterialType" = "Lit"
                                                                            "Queue" = "Transparent"
                                                                            "ShaderGraphShader" = "true"
                                                                            "ShaderGraphTargetId" = "BuiltInLitSubTarget"
                                                                        }
                                                                        Pass
                                                                        {
                                                                            Name "BuiltIn Forward"
                                                                            Tags
                                                                            {
                                                                                "LightMode" = "ForwardBase"
                                                                            }

                                                                        // Render State
                                                                        Cull Back
                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                        ZTest LEqual
                                                                        ZWrite Off
                                                                        ColorMask RGB

                                                                        // Debug
                                                                        // <None>

                                                                        // --------------------------------------------------
                                                                        // Pass

                                                                        HLSLPROGRAM

                                                                        // Pragmas
                                                                        #pragma target 3.0
                                                                        #pragma multi_compile_instancing
                                                                        #pragma multi_compile_fog
                                                                        #pragma multi_compile_fwdbase
                                                                        #pragma vertex vert
                                                                        #pragma fragment frag

                                                                        // DotsInstancingOptions: <None>
                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                        // Keywords
                                                                        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
                                                                        #pragma multi_compile _ LIGHTMAP_ON
                                                                        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                                                        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                                                        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
                                                                        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                                                                        #pragma multi_compile _ _SHADOWS_SOFT
                                                                        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                                                        #pragma multi_compile _ SHADOWS_SHADOWMASK
                                                                        // GraphKeywords: <None>

                                                                        // Defines
                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                        #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                                        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                        #define FEATURES_GRAPH_VERTEX
                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                        #define SHADERPASS SHADERPASS_FORWARD
                                                                        #define BUILTIN_TARGET_API 1
                                                                        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                                                        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                        #endif
                                                                        #ifdef _BUILTIN_ALPHATEST_ON
                                                                        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                                        #endif
                                                                        #ifdef _BUILTIN_AlphaClip
                                                                        #define _AlphaClip _BUILTIN_AlphaClip
                                                                        #endif
                                                                        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                        #endif


                                                                        // custom interpolator pre-include
                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                        // Includes
                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                        // --------------------------------------------------
                                                                        // Structs and Packing

                                                                        // custom interpolators pre packing
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                        struct Attributes
                                                                        {
                                                                             float3 positionOS : POSITION;
                                                                             float3 normalOS : NORMAL;
                                                                             float4 tangentOS : TANGENT;
                                                                             float4 uv1 : TEXCOORD1;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 positionWS;
                                                                             float3 normalWS;
                                                                             float4 tangentWS;
                                                                             float3 viewDirectionWS;
                                                                            #if defined(LIGHTMAP_ON)
                                                                             float2 lightmapUV;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                             float3 sh;
                                                                            #endif
                                                                             float4 fogFactorAndVertexLight;
                                                                             float4 shadowCoord;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct SurfaceDescriptionInputs
                                                                        {
                                                                             float3 TangentSpaceNormal;
                                                                             float3 WorldSpacePosition;
                                                                             float4 ScreenPosition;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                             float3 ObjectSpaceNormal;
                                                                             float3 ObjectSpaceTangent;
                                                                             float3 ObjectSpacePosition;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 interp0 : INTERP0;
                                                                             float3 interp1 : INTERP1;
                                                                             float4 interp2 : INTERP2;
                                                                             float3 interp3 : INTERP3;
                                                                             float2 interp4 : INTERP4;
                                                                             float3 interp5 : INTERP5;
                                                                             float4 interp6 : INTERP6;
                                                                             float4 interp7 : INTERP7;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };

                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                        {
                                                                            PackedVaryings output;
                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                            output.positionCS = input.positionCS;
                                                                            output.interp0.xyz = input.positionWS;
                                                                            output.interp1.xyz = input.normalWS;
                                                                            output.interp2.xyzw = input.tangentWS;
                                                                            output.interp3.xyz = input.viewDirectionWS;
                                                                            #if defined(LIGHTMAP_ON)
                                                                            output.interp4.xy = input.lightmapUV;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                            output.interp5.xyz = input.sh;
                                                                            #endif
                                                                            output.interp6.xyzw = input.fogFactorAndVertexLight;
                                                                            output.interp7.xyzw = input.shadowCoord;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }

                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                        {
                                                                            Varyings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.positionWS = input.interp0.xyz;
                                                                            output.normalWS = input.interp1.xyz;
                                                                            output.tangentWS = input.interp2.xyzw;
                                                                            output.viewDirectionWS = input.interp3.xyz;
                                                                            #if defined(LIGHTMAP_ON)
                                                                            output.lightmapUV = input.interp4.xy;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                            output.sh = input.interp5.xyz;
                                                                            #endif
                                                                            output.fogFactorAndVertexLight = input.interp6.xyzw;
                                                                            output.shadowCoord = input.interp7.xyzw;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }


                                                                        // --------------------------------------------------
                                                                        // Graph

                                                                        // Graph Properties
                                                                        CBUFFER_START(UnityPerMaterial)
                                                                        float2 _Position;
                                                                        float _Size;
                                                                        float _Smoothness;
                                                                        float _Opacity;
                                                                        CBUFFER_END

                                                                            // Object and Global properties

                                                                            // -- Property used by ScenePickingPass
                                                                            #ifdef SCENEPICKINGPASS
                                                                            float4 _SelectionID;
                                                                            #endif

                                                                        // -- Properties used by SceneSelectionPass
                                                                        #ifdef SCENESELECTIONPASS
                                                                        int _ObjectId;
                                                                        int _PassValue;
                                                                        #endif

                                                                        // Graph Includes
                                                                        // GraphIncludes: <None>

                                                                        // Graph Functions

                                                                        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                        {
                                                                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                        }

                                                                        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                        {
                                                                            Out = A + B;
                                                                        }

                                                                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                        {
                                                                            Out = UV * Tiling + Offset;
                                                                        }

                                                                        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                        {
                                                                            Out = A * B;
                                                                        }

                                                                        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                        {
                                                                            Out = A - B;
                                                                        }

                                                                        void Unity_Divide_float(float A, float B, out float Out)
                                                                        {
                                                                            Out = A / B;
                                                                        }

                                                                        void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                        {
                                                                            Out = A * B;
                                                                        }

                                                                        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                        {
                                                                            Out = A / B;
                                                                        }

                                                                        void Unity_Length_float2(float2 In, out float Out)
                                                                        {
                                                                            Out = length(In);
                                                                        }

                                                                        void Unity_OneMinus_float(float In, out float Out)
                                                                        {
                                                                            Out = 1 - In;
                                                                        }

                                                                        void Unity_Saturate_float(float In, out float Out)
                                                                        {
                                                                            Out = saturate(In);
                                                                        }

                                                                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                        {
                                                                            Out = smoothstep(Edge1, Edge2, In);
                                                                        }

                                                                        // Custom interpolators pre vertex
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                        // Graph Vertex
                                                                        struct VertexDescription
                                                                        {
                                                                            float3 Position;
                                                                            float3 Normal;
                                                                            float3 Tangent;
                                                                        };

                                                                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                        {
                                                                            VertexDescription description = (VertexDescription)0;
                                                                            description.Position = IN.ObjectSpacePosition;
                                                                            description.Normal = IN.ObjectSpaceNormal;
                                                                            description.Tangent = IN.ObjectSpaceTangent;
                                                                            return description;
                                                                        }

                                                                        // Custom interpolators, pre surface
                                                                        #ifdef FEATURES_GRAPH_VERTEX
                                                                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                        {
                                                                        return output;
                                                                        }
                                                                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                        #endif

                                                                        // Graph Pixel
                                                                        struct SurfaceDescription
                                                                        {
                                                                            float3 BaseColor;
                                                                            float3 NormalTS;
                                                                            float3 Emission;
                                                                            float Metallic;
                                                                            float Smoothness;
                                                                            float Occlusion;
                                                                            float Alpha;
                                                                        };

                                                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                        {
                                                                            SurfaceDescription surface = (SurfaceDescription)0;
                                                                            float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                                            float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                            float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                                            float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                                            Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                                            float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                                            Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                                            float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                                            Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                                            float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                                            Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                                            float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                                            Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                                            float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                                            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                                            float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                                            float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                                            Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                                            float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                                            float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                                            Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                                            float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                                            Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                                            float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                                            Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                                            float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                                            Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                                            float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                                            Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                                            float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                                            float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                                            Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                                            float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                            Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                                            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                                                                            surface.NormalTS = IN.TangentSpaceNormal;
                                                                            surface.Emission = float3(0, 0, 0);
                                                                            surface.Metallic = 0;
                                                                            surface.Smoothness = 0;
                                                                            surface.Occlusion = 0;
                                                                            surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                            return surface;
                                                                        }

                                                                        // --------------------------------------------------
                                                                        // Build Graph Inputs

                                                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                        {
                                                                            VertexDescriptionInputs output;
                                                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                            output.ObjectSpaceNormal = input.normalOS;
                                                                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                            output.ObjectSpacePosition = input.positionOS;

                                                                            return output;
                                                                        }
                                                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                        {
                                                                            SurfaceDescriptionInputs output;
                                                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                            output.WorldSpacePosition = input.positionWS;
                                                                            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                        #else
                                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                        #endif
                                                                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                return output;
                                                                        }

                                                                        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                                        {
                                                                            result.vertex = float4(attributes.positionOS, 1);
                                                                            result.tangent = attributes.tangentOS;
                                                                            result.normal = attributes.normalOS;
                                                                            result.texcoord1 = attributes.uv1;
                                                                            result.vertex = float4(vertexDescription.Position, 1);
                                                                            result.normal = vertexDescription.Normal;
                                                                            result.tangent = float4(vertexDescription.Tangent, 0);
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            #endif
                                                                        }

                                                                        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                                        {
                                                                            result.pos = varyings.positionCS;
                                                                            result.worldPos = varyings.positionWS;
                                                                            result.worldNormal = varyings.normalWS;
                                                                            result.viewDir = varyings.viewDirectionWS;
                                                                            // World Tangent isn't an available input on v2f_surf

                                                                            result._ShadowCoord = varyings.shadowCoord;

                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            #endif
                                                                            #if UNITY_SHOULD_SAMPLE_SH
                                                                            result.sh = varyings.sh;
                                                                            #endif
                                                                            #if defined(LIGHTMAP_ON)
                                                                            result.lmap.xy = varyings.lightmapUV;
                                                                            #endif
                                                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                                            #endif

                                                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                                        }

                                                                        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                                        {
                                                                            result.positionCS = surfVertex.pos;
                                                                            result.positionWS = surfVertex.worldPos;
                                                                            result.normalWS = surfVertex.worldNormal;
                                                                            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                                            // World Tangent isn't an available input on v2f_surf
                                                                            result.shadowCoord = surfVertex._ShadowCoord;

                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            #endif
                                                                            #if UNITY_SHOULD_SAMPLE_SH
                                                                            result.sh = surfVertex.sh;
                                                                            #endif
                                                                            #if defined(LIGHTMAP_ON)
                                                                            result.lightmapUV = surfVertex.lmap.xy;
                                                                            #endif
                                                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                                            #endif

                                                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                                        }

                                                                        // --------------------------------------------------
                                                                        // Main

                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                                                                        ENDHLSL
                                                                        }
                                                                        Pass
                                                                        {
                                                                            Name "BuiltIn ForwardAdd"
                                                                            Tags
                                                                            {
                                                                                "LightMode" = "ForwardAdd"
                                                                            }

                                                                            // Render State
                                                                            Blend SrcAlpha One
                                                                            ZWrite Off
                                                                            ColorMask RGB

                                                                            // Debug
                                                                            // <None>

                                                                            // --------------------------------------------------
                                                                            // Pass

                                                                            HLSLPROGRAM

                                                                            // Pragmas
                                                                            #pragma target 3.0
                                                                            #pragma multi_compile_instancing
                                                                            #pragma multi_compile_fog
                                                                            #pragma multi_compile_fwdadd_fullshadows
                                                                            #pragma vertex vert
                                                                            #pragma fragment frag

                                                                            // DotsInstancingOptions: <None>
                                                                            // HybridV1InjectedBuiltinProperties: <None>

                                                                            // Keywords
                                                                            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
                                                                            #pragma multi_compile _ LIGHTMAP_ON
                                                                            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                                                            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                                                            #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
                                                                            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                                                                            #pragma multi_compile _ _SHADOWS_SOFT
                                                                            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                                                            #pragma multi_compile _ SHADOWS_SHADOWMASK
                                                                            // GraphKeywords: <None>

                                                                            // Defines
                                                                            #define _NORMALMAP 1
                                                                            #define _NORMAL_DROPOFF_TS 1
                                                                            #define ATTRIBUTES_NEED_NORMAL
                                                                            #define ATTRIBUTES_NEED_TANGENT
                                                                            #define ATTRIBUTES_NEED_TEXCOORD1
                                                                            #define VARYINGS_NEED_POSITION_WS
                                                                            #define VARYINGS_NEED_NORMAL_WS
                                                                            #define VARYINGS_NEED_TANGENT_WS
                                                                            #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                                            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                            #define FEATURES_GRAPH_VERTEX
                                                                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                            #define SHADERPASS SHADERPASS_FORWARD_ADD
                                                                            #define BUILTIN_TARGET_API 1
                                                                            #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                                                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                                                            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                            #endif
                                                                            #ifdef _BUILTIN_ALPHATEST_ON
                                                                            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                                            #endif
                                                                            #ifdef _BUILTIN_AlphaClip
                                                                            #define _AlphaClip _BUILTIN_AlphaClip
                                                                            #endif
                                                                            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                            #endif


                                                                            // custom interpolator pre-include
                                                                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                            // Includes
                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                            // --------------------------------------------------
                                                                            // Structs and Packing

                                                                            // custom interpolators pre packing
                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                            struct Attributes
                                                                            {
                                                                                 float3 positionOS : POSITION;
                                                                                 float3 normalOS : NORMAL;
                                                                                 float4 tangentOS : TANGENT;
                                                                                 float4 uv1 : TEXCOORD1;
                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                 uint instanceID : INSTANCEID_SEMANTIC;
                                                                                #endif
                                                                            };
                                                                            struct Varyings
                                                                            {
                                                                                 float4 positionCS : SV_POSITION;
                                                                                 float3 positionWS;
                                                                                 float3 normalWS;
                                                                                 float4 tangentWS;
                                                                                 float3 viewDirectionWS;
                                                                                #if defined(LIGHTMAP_ON)
                                                                                 float2 lightmapUV;
                                                                                #endif
                                                                                #if !defined(LIGHTMAP_ON)
                                                                                 float3 sh;
                                                                                #endif
                                                                                 float4 fogFactorAndVertexLight;
                                                                                 float4 shadowCoord;
                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                #endif
                                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                #endif
                                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                #endif
                                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                #endif
                                                                            };
                                                                            struct SurfaceDescriptionInputs
                                                                            {
                                                                                 float3 TangentSpaceNormal;
                                                                                 float3 WorldSpacePosition;
                                                                                 float4 ScreenPosition;
                                                                            };
                                                                            struct VertexDescriptionInputs
                                                                            {
                                                                                 float3 ObjectSpaceNormal;
                                                                                 float3 ObjectSpaceTangent;
                                                                                 float3 ObjectSpacePosition;
                                                                            };
                                                                            struct PackedVaryings
                                                                            {
                                                                                 float4 positionCS : SV_POSITION;
                                                                                 float3 interp0 : INTERP0;
                                                                                 float3 interp1 : INTERP1;
                                                                                 float4 interp2 : INTERP2;
                                                                                 float3 interp3 : INTERP3;
                                                                                 float2 interp4 : INTERP4;
                                                                                 float3 interp5 : INTERP5;
                                                                                 float4 interp6 : INTERP6;
                                                                                 float4 interp7 : INTERP7;
                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                #endif
                                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                #endif
                                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                #endif
                                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                #endif
                                                                            };

                                                                            PackedVaryings PackVaryings(Varyings input)
                                                                            {
                                                                                PackedVaryings output;
                                                                                ZERO_INITIALIZE(PackedVaryings, output);
                                                                                output.positionCS = input.positionCS;
                                                                                output.interp0.xyz = input.positionWS;
                                                                                output.interp1.xyz = input.normalWS;
                                                                                output.interp2.xyzw = input.tangentWS;
                                                                                output.interp3.xyz = input.viewDirectionWS;
                                                                                #if defined(LIGHTMAP_ON)
                                                                                output.interp4.xy = input.lightmapUV;
                                                                                #endif
                                                                                #if !defined(LIGHTMAP_ON)
                                                                                output.interp5.xyz = input.sh;
                                                                                #endif
                                                                                output.interp6.xyzw = input.fogFactorAndVertexLight;
                                                                                output.interp7.xyzw = input.shadowCoord;
                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                output.instanceID = input.instanceID;
                                                                                #endif
                                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                #endif
                                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                #endif
                                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                output.cullFace = input.cullFace;
                                                                                #endif
                                                                                return output;
                                                                            }

                                                                            Varyings UnpackVaryings(PackedVaryings input)
                                                                            {
                                                                                Varyings output;
                                                                                output.positionCS = input.positionCS;
                                                                                output.positionWS = input.interp0.xyz;
                                                                                output.normalWS = input.interp1.xyz;
                                                                                output.tangentWS = input.interp2.xyzw;
                                                                                output.viewDirectionWS = input.interp3.xyz;
                                                                                #if defined(LIGHTMAP_ON)
                                                                                output.lightmapUV = input.interp4.xy;
                                                                                #endif
                                                                                #if !defined(LIGHTMAP_ON)
                                                                                output.sh = input.interp5.xyz;
                                                                                #endif
                                                                                output.fogFactorAndVertexLight = input.interp6.xyzw;
                                                                                output.shadowCoord = input.interp7.xyzw;
                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                output.instanceID = input.instanceID;
                                                                                #endif
                                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                #endif
                                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                #endif
                                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                output.cullFace = input.cullFace;
                                                                                #endif
                                                                                return output;
                                                                            }


                                                                            // --------------------------------------------------
                                                                            // Graph

                                                                            // Graph Properties
                                                                            CBUFFER_START(UnityPerMaterial)
                                                                            float2 _Position;
                                                                            float _Size;
                                                                            float _Smoothness;
                                                                            float _Opacity;
                                                                            CBUFFER_END

                                                                                // Object and Global properties

                                                                                // -- Property used by ScenePickingPass
                                                                                #ifdef SCENEPICKINGPASS
                                                                                float4 _SelectionID;
                                                                                #endif

                                                                            // -- Properties used by SceneSelectionPass
                                                                            #ifdef SCENESELECTIONPASS
                                                                            int _ObjectId;
                                                                            int _PassValue;
                                                                            #endif

                                                                            // Graph Includes
                                                                            // GraphIncludes: <None>

                                                                            // Graph Functions

                                                                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                            {
                                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                            }

                                                                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                            {
                                                                                Out = UV * Tiling + Offset;
                                                                            }

                                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A - B;
                                                                            }

                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A / B;
                                                                            }

                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A / B;
                                                                            }

                                                                            void Unity_Length_float2(float2 In, out float Out)
                                                                            {
                                                                                Out = length(In);
                                                                            }

                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                            {
                                                                                Out = 1 - In;
                                                                            }

                                                                            void Unity_Saturate_float(float In, out float Out)
                                                                            {
                                                                                Out = saturate(In);
                                                                            }

                                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                            {
                                                                                Out = smoothstep(Edge1, Edge2, In);
                                                                            }

                                                                            // Custom interpolators pre vertex
                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                            // Graph Vertex
                                                                            struct VertexDescription
                                                                            {
                                                                                float3 Position;
                                                                                float3 Normal;
                                                                                float3 Tangent;
                                                                            };

                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                            {
                                                                                VertexDescription description = (VertexDescription)0;
                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                return description;
                                                                            }

                                                                            // Custom interpolators, pre surface
                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                            {
                                                                            return output;
                                                                            }
                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                            #endif

                                                                            // Graph Pixel
                                                                            struct SurfaceDescription
                                                                            {
                                                                                float3 BaseColor;
                                                                                float3 NormalTS;
                                                                                float3 Emission;
                                                                                float Metallic;
                                                                                float Smoothness;
                                                                                float Occlusion;
                                                                                float Alpha;
                                                                            };

                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                            {
                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                                                float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                                                float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                                                Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                                                float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                                                Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                                                float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                                                Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                                                float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                                                Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                                                float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                                                Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                                                float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                                                float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                                                float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                                                Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                                                float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                                                float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                                                Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                                                float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                                                Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                                                float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                                                Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                                                float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                                                Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                                                float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                                                Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                                                float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                                                float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                                                Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                                                float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                                                surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                surface.Emission = float3(0, 0, 0);
                                                                                surface.Metallic = 0;
                                                                                surface.Smoothness = 0;
                                                                                surface.Occlusion = 0;
                                                                                surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                return surface;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Build Graph Inputs

                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                            {
                                                                                VertexDescriptionInputs output;
                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                return output;
                                                                            }
                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                            #else
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                            #endif
                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                    return output;
                                                                            }

                                                                            void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                                            {
                                                                                result.vertex = float4(attributes.positionOS, 1);
                                                                                result.tangent = attributes.tangentOS;
                                                                                result.normal = attributes.normalOS;
                                                                                result.texcoord1 = attributes.uv1;
                                                                                result.vertex = float4(vertexDescription.Position, 1);
                                                                                result.normal = vertexDescription.Normal;
                                                                                result.tangent = float4(vertexDescription.Tangent, 0);
                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                #endif
                                                                            }

                                                                            void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                                            {
                                                                                result.pos = varyings.positionCS;
                                                                                result.worldPos = varyings.positionWS;
                                                                                result.worldNormal = varyings.normalWS;
                                                                                result.viewDir = varyings.viewDirectionWS;
                                                                                // World Tangent isn't an available input on v2f_surf

                                                                                result._ShadowCoord = varyings.shadowCoord;

                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                #endif
                                                                                #if UNITY_SHOULD_SAMPLE_SH
                                                                                result.sh = varyings.sh;
                                                                                #endif
                                                                                #if defined(LIGHTMAP_ON)
                                                                                result.lmap.xy = varyings.lightmapUV;
                                                                                #endif
                                                                                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                    result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                                    COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                                                #endif

                                                                                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                                            }

                                                                            void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                                            {
                                                                                result.positionCS = surfVertex.pos;
                                                                                result.positionWS = surfVertex.worldPos;
                                                                                result.normalWS = surfVertex.worldNormal;
                                                                                // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                                                // World Tangent isn't an available input on v2f_surf
                                                                                result.shadowCoord = surfVertex._ShadowCoord;

                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                #endif
                                                                                #if UNITY_SHOULD_SAMPLE_SH
                                                                                result.sh = surfVertex.sh;
                                                                                #endif
                                                                                #if defined(LIGHTMAP_ON)
                                                                                result.lightmapUV = surfVertex.lmap.xy;
                                                                                #endif
                                                                                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                    result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                                    COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                                                #endif

                                                                                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Main

                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardAddPass.hlsl"

                                                                            ENDHLSL
                                                                            }
                                                                            Pass
                                                                            {
                                                                                Name "BuiltIn Deferred"
                                                                                Tags
                                                                                {
                                                                                    "LightMode" = "Deferred"
                                                                                }

                                                                                // Render State
                                                                                Cull Back
                                                                                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                                ZTest LEqual
                                                                                ZWrite Off
                                                                                ColorMask RGB

                                                                                // Debug
                                                                                // <None>

                                                                                // --------------------------------------------------
                                                                                // Pass

                                                                                HLSLPROGRAM

                                                                                // Pragmas
                                                                                #pragma target 4.5
                                                                                #pragma multi_compile_instancing
                                                                                #pragma exclude_renderers nomrt
                                                                                #pragma multi_compile_prepassfinal
                                                                                #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
                                                                                #pragma vertex vert
                                                                                #pragma fragment frag

                                                                                // DotsInstancingOptions: <None>
                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                // Keywords
                                                                                #pragma multi_compile _ LIGHTMAP_ON
                                                                                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                                                                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                                                                #pragma multi_compile _ _SHADOWS_SOFT
                                                                                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                                                                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                                                                                #pragma multi_compile _ _GBUFFER_NORMALS_OCT
                                                                                // GraphKeywords: <None>

                                                                                // Defines
                                                                                #define _NORMALMAP 1
                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                                #define VARYINGS_NEED_TANGENT_WS
                                                                                #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                                                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                #define SHADERPASS SHADERPASS_DEFERRED
                                                                                #define BUILTIN_TARGET_API 1
                                                                                #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                                                                #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                                #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                                #endif
                                                                                #ifdef _BUILTIN_ALPHATEST_ON
                                                                                #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                                                #endif
                                                                                #ifdef _BUILTIN_AlphaClip
                                                                                #define _AlphaClip _BUILTIN_AlphaClip
                                                                                #endif
                                                                                #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                                #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                                #endif


                                                                                // custom interpolator pre-include
                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                // Includes
                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                                // --------------------------------------------------
                                                                                // Structs and Packing

                                                                                // custom interpolators pre packing
                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                struct Attributes
                                                                                {
                                                                                     float3 positionOS : POSITION;
                                                                                     float3 normalOS : NORMAL;
                                                                                     float4 tangentOS : TANGENT;
                                                                                     float4 uv1 : TEXCOORD1;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct Varyings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 positionWS;
                                                                                     float3 normalWS;
                                                                                     float4 tangentWS;
                                                                                     float3 viewDirectionWS;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                     float2 lightmapUV;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                     float3 sh;
                                                                                    #endif
                                                                                     float4 fogFactorAndVertexLight;
                                                                                     float4 shadowCoord;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct SurfaceDescriptionInputs
                                                                                {
                                                                                     float3 TangentSpaceNormal;
                                                                                     float3 WorldSpacePosition;
                                                                                     float4 ScreenPosition;
                                                                                };
                                                                                struct VertexDescriptionInputs
                                                                                {
                                                                                     float3 ObjectSpaceNormal;
                                                                                     float3 ObjectSpaceTangent;
                                                                                     float3 ObjectSpacePosition;
                                                                                };
                                                                                struct PackedVaryings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 interp0 : INTERP0;
                                                                                     float3 interp1 : INTERP1;
                                                                                     float4 interp2 : INTERP2;
                                                                                     float3 interp3 : INTERP3;
                                                                                     float2 interp4 : INTERP4;
                                                                                     float3 interp5 : INTERP5;
                                                                                     float4 interp6 : INTERP6;
                                                                                     float4 interp7 : INTERP7;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };

                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                {
                                                                                    PackedVaryings output;
                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.interp0.xyz = input.positionWS;
                                                                                    output.interp1.xyz = input.normalWS;
                                                                                    output.interp2.xyzw = input.tangentWS;
                                                                                    output.interp3.xyz = input.viewDirectionWS;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                    output.interp4.xy = input.lightmapUV;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                    output.interp5.xyz = input.sh;
                                                                                    #endif
                                                                                    output.interp6.xyzw = input.fogFactorAndVertexLight;
                                                                                    output.interp7.xyzw = input.shadowCoord;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }

                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                {
                                                                                    Varyings output;
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.positionWS = input.interp0.xyz;
                                                                                    output.normalWS = input.interp1.xyz;
                                                                                    output.tangentWS = input.interp2.xyzw;
                                                                                    output.viewDirectionWS = input.interp3.xyz;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                    output.lightmapUV = input.interp4.xy;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                    output.sh = input.interp5.xyz;
                                                                                    #endif
                                                                                    output.fogFactorAndVertexLight = input.interp6.xyzw;
                                                                                    output.shadowCoord = input.interp7.xyzw;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }


                                                                                // --------------------------------------------------
                                                                                // Graph

                                                                                // Graph Properties
                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                float2 _Position;
                                                                                float _Size;
                                                                                float _Smoothness;
                                                                                float _Opacity;
                                                                                CBUFFER_END

                                                                                    // Object and Global properties

                                                                                    // -- Property used by ScenePickingPass
                                                                                    #ifdef SCENEPICKINGPASS
                                                                                    float4 _SelectionID;
                                                                                    #endif

                                                                                // -- Properties used by SceneSelectionPass
                                                                                #ifdef SCENESELECTIONPASS
                                                                                int _ObjectId;
                                                                                int _PassValue;
                                                                                #endif

                                                                                // Graph Includes
                                                                                // GraphIncludes: <None>

                                                                                // Graph Functions

                                                                                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                                {
                                                                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                }

                                                                                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                                {
                                                                                    Out = A + B;
                                                                                }

                                                                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                {
                                                                                    Out = UV * Tiling + Offset;
                                                                                }

                                                                                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                {
                                                                                    Out = A * B;
                                                                                }

                                                                                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                {
                                                                                    Out = A - B;
                                                                                }

                                                                                void Unity_Divide_float(float A, float B, out float Out)
                                                                                {
                                                                                    Out = A / B;
                                                                                }

                                                                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                {
                                                                                    Out = A * B;
                                                                                }

                                                                                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                {
                                                                                    Out = A / B;
                                                                                }

                                                                                void Unity_Length_float2(float2 In, out float Out)
                                                                                {
                                                                                    Out = length(In);
                                                                                }

                                                                                void Unity_OneMinus_float(float In, out float Out)
                                                                                {
                                                                                    Out = 1 - In;
                                                                                }

                                                                                void Unity_Saturate_float(float In, out float Out)
                                                                                {
                                                                                    Out = saturate(In);
                                                                                }

                                                                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                {
                                                                                    Out = smoothstep(Edge1, Edge2, In);
                                                                                }

                                                                                // Custom interpolators pre vertex
                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                // Graph Vertex
                                                                                struct VertexDescription
                                                                                {
                                                                                    float3 Position;
                                                                                    float3 Normal;
                                                                                    float3 Tangent;
                                                                                };

                                                                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                {
                                                                                    VertexDescription description = (VertexDescription)0;
                                                                                    description.Position = IN.ObjectSpacePosition;
                                                                                    description.Normal = IN.ObjectSpaceNormal;
                                                                                    description.Tangent = IN.ObjectSpaceTangent;
                                                                                    return description;
                                                                                }

                                                                                // Custom interpolators, pre surface
                                                                                #ifdef FEATURES_GRAPH_VERTEX
                                                                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                {
                                                                                return output;
                                                                                }
                                                                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                #endif

                                                                                // Graph Pixel
                                                                                struct SurfaceDescription
                                                                                {
                                                                                    float3 BaseColor;
                                                                                    float3 NormalTS;
                                                                                    float3 Emission;
                                                                                    float Metallic;
                                                                                    float Smoothness;
                                                                                    float Occlusion;
                                                                                    float Alpha;
                                                                                };

                                                                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                {
                                                                                    SurfaceDescription surface = (SurfaceDescription)0;
                                                                                    float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                                                    float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                    float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                                                    float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                                                    Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                                                    float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                                                    Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                                                    float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                                                    Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                                                    float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                                                    Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                                                    float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                                                    Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                                                    float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                                                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                                                    float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                                                    float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                                                    Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                                                    float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                                                    float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                                                    Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                                                    float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                                                    Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                                                    float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                                                    Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                                                    float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                                                    Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                                                    float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                                                    Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                                                    float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                                                    float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                                                    Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                                                    float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                    Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                                                    surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                                                                                    surface.NormalTS = IN.TangentSpaceNormal;
                                                                                    surface.Emission = float3(0, 0, 0);
                                                                                    surface.Metallic = 0;
                                                                                    surface.Smoothness = 0;
                                                                                    surface.Occlusion = 0;
                                                                                    surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                    return surface;
                                                                                }

                                                                                // --------------------------------------------------
                                                                                // Build Graph Inputs

                                                                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                {
                                                                                    VertexDescriptionInputs output;
                                                                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                    output.ObjectSpaceNormal = input.normalOS;
                                                                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                    output.ObjectSpacePosition = input.positionOS;

                                                                                    return output;
                                                                                }
                                                                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                {
                                                                                    SurfaceDescriptionInputs output;
                                                                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                    output.WorldSpacePosition = input.positionWS;
                                                                                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                #else
                                                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                #endif
                                                                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                        return output;
                                                                                }

                                                                                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                                                {
                                                                                    result.vertex = float4(attributes.positionOS, 1);
                                                                                    result.tangent = attributes.tangentOS;
                                                                                    result.normal = attributes.normalOS;
                                                                                    result.texcoord1 = attributes.uv1;
                                                                                    result.vertex = float4(vertexDescription.Position, 1);
                                                                                    result.normal = vertexDescription.Normal;
                                                                                    result.tangent = float4(vertexDescription.Tangent, 0);
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    #endif
                                                                                }

                                                                                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                                                {
                                                                                    result.pos = varyings.positionCS;
                                                                                    result.worldPos = varyings.positionWS;
                                                                                    result.worldNormal = varyings.normalWS;
                                                                                    result.viewDir = varyings.viewDirectionWS;
                                                                                    // World Tangent isn't an available input on v2f_surf

                                                                                    result._ShadowCoord = varyings.shadowCoord;

                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    #endif
                                                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                                                    result.sh = varyings.sh;
                                                                                    #endif
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                    result.lmap.xy = varyings.lightmapUV;
                                                                                    #endif
                                                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                                                    #endif

                                                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                                                }

                                                                                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                                                {
                                                                                    result.positionCS = surfVertex.pos;
                                                                                    result.positionWS = surfVertex.worldPos;
                                                                                    result.normalWS = surfVertex.worldNormal;
                                                                                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                                                    // World Tangent isn't an available input on v2f_surf
                                                                                    result.shadowCoord = surfVertex._ShadowCoord;

                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    #endif
                                                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                                                    result.sh = surfVertex.sh;
                                                                                    #endif
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                    result.lightmapUV = surfVertex.lmap.xy;
                                                                                    #endif
                                                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                                                    #endif

                                                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                                                }

                                                                                // --------------------------------------------------
                                                                                // Main

                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRDeferredPass.hlsl"

                                                                                ENDHLSL
                                                                                }
                                                                                Pass
                                                                                {
                                                                                    Name "ShadowCaster"
                                                                                    Tags
                                                                                    {
                                                                                        "LightMode" = "ShadowCaster"
                                                                                    }

                                                                                    // Render State
                                                                                    Cull Back
                                                                                    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                                    ZTest LEqual
                                                                                    ZWrite On
                                                                                    ColorMask 0

                                                                                    // Debug
                                                                                    // <None>

                                                                                    // --------------------------------------------------
                                                                                    // Pass

                                                                                    HLSLPROGRAM

                                                                                    // Pragmas
                                                                                    #pragma target 3.0
                                                                                    #pragma multi_compile_shadowcaster
                                                                                    #pragma vertex vert
                                                                                    #pragma fragment frag

                                                                                    // DotsInstancingOptions: <None>
                                                                                    // HybridV1InjectedBuiltinProperties: <None>

                                                                                    // Keywords
                                                                                    #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                                                                    // GraphKeywords: <None>

                                                                                    // Defines
                                                                                    #define _NORMALMAP 1
                                                                                    #define _NORMAL_DROPOFF_TS 1
                                                                                    #define ATTRIBUTES_NEED_NORMAL
                                                                                    #define ATTRIBUTES_NEED_TANGENT
                                                                                    #define VARYINGS_NEED_POSITION_WS
                                                                                    #define FEATURES_GRAPH_VERTEX
                                                                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                    #define SHADERPASS SHADERPASS_SHADOWCASTER
                                                                                    #define BUILTIN_TARGET_API 1
                                                                                    #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                                                                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                                                                    #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                                    #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                                    #endif
                                                                                    #ifdef _BUILTIN_ALPHATEST_ON
                                                                                    #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                                                    #endif
                                                                                    #ifdef _BUILTIN_AlphaClip
                                                                                    #define _AlphaClip _BUILTIN_AlphaClip
                                                                                    #endif
                                                                                    #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                                    #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                                    #endif


                                                                                    // custom interpolator pre-include
                                                                                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                    // Includes
                                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                                    // --------------------------------------------------
                                                                                    // Structs and Packing

                                                                                    // custom interpolators pre packing
                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                    struct Attributes
                                                                                    {
                                                                                         float3 positionOS : POSITION;
                                                                                         float3 normalOS : NORMAL;
                                                                                         float4 tangentOS : TANGENT;
                                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                                         uint instanceID : INSTANCEID_SEMANTIC;
                                                                                        #endif
                                                                                    };
                                                                                    struct Varyings
                                                                                    {
                                                                                         float4 positionCS : SV_POSITION;
                                                                                         float3 positionWS;
                                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                        #endif
                                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                        #endif
                                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                        #endif
                                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                        #endif
                                                                                    };
                                                                                    struct SurfaceDescriptionInputs
                                                                                    {
                                                                                         float3 WorldSpacePosition;
                                                                                         float4 ScreenPosition;
                                                                                    };
                                                                                    struct VertexDescriptionInputs
                                                                                    {
                                                                                         float3 ObjectSpaceNormal;
                                                                                         float3 ObjectSpaceTangent;
                                                                                         float3 ObjectSpacePosition;
                                                                                    };
                                                                                    struct PackedVaryings
                                                                                    {
                                                                                         float4 positionCS : SV_POSITION;
                                                                                         float3 interp0 : INTERP0;
                                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                        #endif
                                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                        #endif
                                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                        #endif
                                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                        #endif
                                                                                    };

                                                                                    PackedVaryings PackVaryings(Varyings input)
                                                                                    {
                                                                                        PackedVaryings output;
                                                                                        ZERO_INITIALIZE(PackedVaryings, output);
                                                                                        output.positionCS = input.positionCS;
                                                                                        output.interp0.xyz = input.positionWS;
                                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                                        output.instanceID = input.instanceID;
                                                                                        #endif
                                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                        #endif
                                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                        #endif
                                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                        output.cullFace = input.cullFace;
                                                                                        #endif
                                                                                        return output;
                                                                                    }

                                                                                    Varyings UnpackVaryings(PackedVaryings input)
                                                                                    {
                                                                                        Varyings output;
                                                                                        output.positionCS = input.positionCS;
                                                                                        output.positionWS = input.interp0.xyz;
                                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                                        output.instanceID = input.instanceID;
                                                                                        #endif
                                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                        #endif
                                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                        #endif
                                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                        output.cullFace = input.cullFace;
                                                                                        #endif
                                                                                        return output;
                                                                                    }


                                                                                    // --------------------------------------------------
                                                                                    // Graph

                                                                                    // Graph Properties
                                                                                    CBUFFER_START(UnityPerMaterial)
                                                                                    float2 _Position;
                                                                                    float _Size;
                                                                                    float _Smoothness;
                                                                                    float _Opacity;
                                                                                    CBUFFER_END

                                                                                        // Object and Global properties

                                                                                        // -- Property used by ScenePickingPass
                                                                                        #ifdef SCENEPICKINGPASS
                                                                                        float4 _SelectionID;
                                                                                        #endif

                                                                                    // -- Properties used by SceneSelectionPass
                                                                                    #ifdef SCENESELECTIONPASS
                                                                                    int _ObjectId;
                                                                                    int _PassValue;
                                                                                    #endif

                                                                                    // Graph Includes
                                                                                    // GraphIncludes: <None>

                                                                                    // Graph Functions

                                                                                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                                    {
                                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                    }

                                                                                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A + B;
                                                                                    }

                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                    {
                                                                                        Out = UV * Tiling + Offset;
                                                                                    }

                                                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A - B;
                                                                                    }

                                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A / B;
                                                                                    }

                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A / B;
                                                                                    }

                                                                                    void Unity_Length_float2(float2 In, out float Out)
                                                                                    {
                                                                                        Out = length(In);
                                                                                    }

                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                    {
                                                                                        Out = 1 - In;
                                                                                    }

                                                                                    void Unity_Saturate_float(float In, out float Out)
                                                                                    {
                                                                                        Out = saturate(In);
                                                                                    }

                                                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                    {
                                                                                        Out = smoothstep(Edge1, Edge2, In);
                                                                                    }

                                                                                    // Custom interpolators pre vertex
                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                    // Graph Vertex
                                                                                    struct VertexDescription
                                                                                    {
                                                                                        float3 Position;
                                                                                        float3 Normal;
                                                                                        float3 Tangent;
                                                                                    };

                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                    {
                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                        return description;
                                                                                    }

                                                                                    // Custom interpolators, pre surface
                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                    {
                                                                                    return output;
                                                                                    }
                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                    #endif

                                                                                    // Graph Pixel
                                                                                    struct SurfaceDescription
                                                                                    {
                                                                                        float Alpha;
                                                                                    };

                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                    {
                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                        float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                                                        float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                        float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                                                        float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                                                        Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                                                        float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                                                        Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                                                        float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                                                        Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                                                        float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                                                        Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                                                        float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                                                        Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                                                        float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                                                        float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                                                        float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                                                        Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                                                        float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                                                        float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                                                        Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                                                        float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                                                        Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                                                        float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                                                        Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                                                        float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                                                        Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                                                        float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                                                        Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                                                        float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                                                        float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                                                        Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                                                        float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                        Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                                                        surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                        return surface;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Build Graph Inputs

                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                    {
                                                                                        VertexDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                        return output;
                                                                                    }
                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                    {
                                                                                        SurfaceDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                    #else
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                    #endif
                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                            return output;
                                                                                    }

                                                                                    void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                                                    {
                                                                                        result.vertex = float4(attributes.positionOS, 1);
                                                                                        result.tangent = attributes.tangentOS;
                                                                                        result.normal = attributes.normalOS;
                                                                                        result.vertex = float4(vertexDescription.Position, 1);
                                                                                        result.normal = vertexDescription.Normal;
                                                                                        result.tangent = float4(vertexDescription.Tangent, 0);
                                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                                        #endif
                                                                                    }

                                                                                    void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                                                    {
                                                                                        result.pos = varyings.positionCS;
                                                                                        result.worldPos = varyings.positionWS;
                                                                                        // World Tangent isn't an available input on v2f_surf


                                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                                        #endif
                                                                                        #if UNITY_SHOULD_SAMPLE_SH
                                                                                        #endif
                                                                                        #if defined(LIGHTMAP_ON)
                                                                                        #endif
                                                                                        #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                            result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                                            COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                                                        #endif

                                                                                        DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                                                    }

                                                                                    void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                                                    {
                                                                                        result.positionCS = surfVertex.pos;
                                                                                        result.positionWS = surfVertex.worldPos;
                                                                                        // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                                                        // World Tangent isn't an available input on v2f_surf

                                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                                        #endif
                                                                                        #if UNITY_SHOULD_SAMPLE_SH
                                                                                        #endif
                                                                                        #if defined(LIGHTMAP_ON)
                                                                                        #endif
                                                                                        #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                            result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                                            COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                                                        #endif

                                                                                        DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Main

                                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                                                                    ENDHLSL
                                                                                    }
                                                                                    Pass
                                                                                    {
                                                                                        Name "Meta"
                                                                                        Tags
                                                                                        {
                                                                                            "LightMode" = "Meta"
                                                                                        }

                                                                                        // Render State
                                                                                        Cull Off

                                                                                        // Debug
                                                                                        // <None>

                                                                                        // --------------------------------------------------
                                                                                        // Pass

                                                                                        HLSLPROGRAM

                                                                                        // Pragmas
                                                                                        #pragma target 3.0
                                                                                        #pragma vertex vert
                                                                                        #pragma fragment frag

                                                                                        // DotsInstancingOptions: <None>
                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                        // Keywords
                                                                                        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                                                                                        // GraphKeywords: <None>

                                                                                        // Defines
                                                                                        #define _NORMALMAP 1
                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                        #define SHADERPASS SHADERPASS_META
                                                                                        #define BUILTIN_TARGET_API 1
                                                                                        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                                                                        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                                        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                                        #endif
                                                                                        #ifdef _BUILTIN_ALPHATEST_ON
                                                                                        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                                                        #endif
                                                                                        #ifdef _BUILTIN_AlphaClip
                                                                                        #define _AlphaClip _BUILTIN_AlphaClip
                                                                                        #endif
                                                                                        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                                        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                                        #endif


                                                                                        // custom interpolator pre-include
                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                        // Includes
                                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                                        // --------------------------------------------------
                                                                                        // Structs and Packing

                                                                                        // custom interpolators pre packing
                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                        struct Attributes
                                                                                        {
                                                                                             float3 positionOS : POSITION;
                                                                                             float3 normalOS : NORMAL;
                                                                                             float4 tangentOS : TANGENT;
                                                                                             float4 uv1 : TEXCOORD1;
                                                                                             float4 uv2 : TEXCOORD2;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct Varyings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 positionWS;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct SurfaceDescriptionInputs
                                                                                        {
                                                                                             float3 WorldSpacePosition;
                                                                                             float4 ScreenPosition;
                                                                                        };
                                                                                        struct VertexDescriptionInputs
                                                                                        {
                                                                                             float3 ObjectSpaceNormal;
                                                                                             float3 ObjectSpaceTangent;
                                                                                             float3 ObjectSpacePosition;
                                                                                        };
                                                                                        struct PackedVaryings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 interp0 : INTERP0;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };

                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                        {
                                                                                            PackedVaryings output;
                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.interp0.xyz = input.positionWS;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }

                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                        {
                                                                                            Varyings output;
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.positionWS = input.interp0.xyz;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }


                                                                                        // --------------------------------------------------
                                                                                        // Graph

                                                                                        // Graph Properties
                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                        float2 _Position;
                                                                                        float _Size;
                                                                                        float _Smoothness;
                                                                                        float _Opacity;
                                                                                        CBUFFER_END

                                                                                            // Object and Global properties

                                                                                            // -- Property used by ScenePickingPass
                                                                                            #ifdef SCENEPICKINGPASS
                                                                                            float4 _SelectionID;
                                                                                            #endif

                                                                                        // -- Properties used by SceneSelectionPass
                                                                                        #ifdef SCENESELECTIONPASS
                                                                                        int _ObjectId;
                                                                                        int _PassValue;
                                                                                        #endif

                                                                                        // Graph Includes
                                                                                        // GraphIncludes: <None>

                                                                                        // Graph Functions

                                                                                        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                                        {
                                                                                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                        }

                                                                                        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                                        {
                                                                                            Out = A + B;
                                                                                        }

                                                                                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                        {
                                                                                            Out = UV * Tiling + Offset;
                                                                                        }

                                                                                        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                        {
                                                                                            Out = A * B;
                                                                                        }

                                                                                        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                        {
                                                                                            Out = A - B;
                                                                                        }

                                                                                        void Unity_Divide_float(float A, float B, out float Out)
                                                                                        {
                                                                                            Out = A / B;
                                                                                        }

                                                                                        void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                        {
                                                                                            Out = A * B;
                                                                                        }

                                                                                        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                        {
                                                                                            Out = A / B;
                                                                                        }

                                                                                        void Unity_Length_float2(float2 In, out float Out)
                                                                                        {
                                                                                            Out = length(In);
                                                                                        }

                                                                                        void Unity_OneMinus_float(float In, out float Out)
                                                                                        {
                                                                                            Out = 1 - In;
                                                                                        }

                                                                                        void Unity_Saturate_float(float In, out float Out)
                                                                                        {
                                                                                            Out = saturate(In);
                                                                                        }

                                                                                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                        {
                                                                                            Out = smoothstep(Edge1, Edge2, In);
                                                                                        }

                                                                                        // Custom interpolators pre vertex
                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                        // Graph Vertex
                                                                                        struct VertexDescription
                                                                                        {
                                                                                            float3 Position;
                                                                                            float3 Normal;
                                                                                            float3 Tangent;
                                                                                        };

                                                                                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                        {
                                                                                            VertexDescription description = (VertexDescription)0;
                                                                                            description.Position = IN.ObjectSpacePosition;
                                                                                            description.Normal = IN.ObjectSpaceNormal;
                                                                                            description.Tangent = IN.ObjectSpaceTangent;
                                                                                            return description;
                                                                                        }

                                                                                        // Custom interpolators, pre surface
                                                                                        #ifdef FEATURES_GRAPH_VERTEX
                                                                                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                        {
                                                                                        return output;
                                                                                        }
                                                                                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                        #endif

                                                                                        // Graph Pixel
                                                                                        struct SurfaceDescription
                                                                                        {
                                                                                            float3 BaseColor;
                                                                                            float3 Emission;
                                                                                            float Alpha;
                                                                                        };

                                                                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                        {
                                                                                            SurfaceDescription surface = (SurfaceDescription)0;
                                                                                            float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                                                            float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                            float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                                                            float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                                                            Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                                                            float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                                                            Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                                                            float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                                                            Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                                                            float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                                                            Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                                                            float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                                                            Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                                                            float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                                                            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                                                            float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                                                            float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                                                            Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                                                            float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                                                            float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                                                            Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                                                            float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                                                            Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                                                            float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                                                            Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                                                            float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                                                            Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                                                            float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                                                            Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                                                            float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                                                            float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                                                            Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                                                            float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                            Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                                                            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                                                                                            surface.Emission = float3(0, 0, 0);
                                                                                            surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                            return surface;
                                                                                        }

                                                                                        // --------------------------------------------------
                                                                                        // Build Graph Inputs

                                                                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                        {
                                                                                            VertexDescriptionInputs output;
                                                                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                            output.ObjectSpaceNormal = input.normalOS;
                                                                                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                            output.ObjectSpacePosition = input.positionOS;

                                                                                            return output;
                                                                                        }
                                                                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                        {
                                                                                            SurfaceDescriptionInputs output;
                                                                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                                                                            output.WorldSpacePosition = input.positionWS;
                                                                                            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                        #else
                                                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                        #endif
                                                                                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                return output;
                                                                                        }

                                                                                        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                                                        {
                                                                                            result.vertex = float4(attributes.positionOS, 1);
                                                                                            result.tangent = attributes.tangentOS;
                                                                                            result.normal = attributes.normalOS;
                                                                                            result.texcoord1 = attributes.uv1;
                                                                                            result.texcoord2 = attributes.uv2;
                                                                                            result.vertex = float4(vertexDescription.Position, 1);
                                                                                            result.normal = vertexDescription.Normal;
                                                                                            result.tangent = float4(vertexDescription.Tangent, 0);
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            #endif
                                                                                        }

                                                                                        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                                                        {
                                                                                            result.pos = varyings.positionCS;
                                                                                            result.worldPos = varyings.positionWS;
                                                                                            // World Tangent isn't an available input on v2f_surf


                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            #endif
                                                                                            #if UNITY_SHOULD_SAMPLE_SH
                                                                                            #endif
                                                                                            #if defined(LIGHTMAP_ON)
                                                                                            #endif
                                                                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                                                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                                                            #endif

                                                                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                                                        }

                                                                                        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                                                        {
                                                                                            result.positionCS = surfVertex.pos;
                                                                                            result.positionWS = surfVertex.worldPos;
                                                                                            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                                                            // World Tangent isn't an available input on v2f_surf

                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            #endif
                                                                                            #if UNITY_SHOULD_SAMPLE_SH
                                                                                            #endif
                                                                                            #if defined(LIGHTMAP_ON)
                                                                                            #endif
                                                                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                                                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                                                            #endif

                                                                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                                                        }

                                                                                        // --------------------------------------------------
                                                                                        // Main

                                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                                                        ENDHLSL
                                                                                        }
                                                                                        Pass
                                                                                        {
                                                                                            Name "SceneSelectionPass"
                                                                                            Tags
                                                                                            {
                                                                                                "LightMode" = "SceneSelectionPass"
                                                                                            }

                                                                                            // Render State
                                                                                            Cull Off

                                                                                            // Debug
                                                                                            // <None>

                                                                                            // --------------------------------------------------
                                                                                            // Pass

                                                                                            HLSLPROGRAM

                                                                                            // Pragmas
                                                                                            #pragma target 3.0
                                                                                            #pragma multi_compile_instancing
                                                                                            #pragma vertex vert
                                                                                            #pragma fragment frag

                                                                                            // DotsInstancingOptions: <None>
                                                                                            // HybridV1InjectedBuiltinProperties: <None>

                                                                                            // Keywords
                                                                                            // PassKeywords: <None>
                                                                                            // GraphKeywords: <None>

                                                                                            // Defines
                                                                                            #define _NORMALMAP 1
                                                                                            #define _NORMAL_DROPOFF_TS 1
                                                                                            #define ATTRIBUTES_NEED_NORMAL
                                                                                            #define ATTRIBUTES_NEED_TANGENT
                                                                                            #define VARYINGS_NEED_POSITION_WS
                                                                                            #define FEATURES_GRAPH_VERTEX
                                                                                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                            #define SHADERPASS SceneSelectionPass
                                                                                            #define BUILTIN_TARGET_API 1
                                                                                            #define SCENESELECTIONPASS 1
                                                                                            #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                                                                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                                                                            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                                            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                                            #endif
                                                                                            #ifdef _BUILTIN_ALPHATEST_ON
                                                                                            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                                                            #endif
                                                                                            #ifdef _BUILTIN_AlphaClip
                                                                                            #define _AlphaClip _BUILTIN_AlphaClip
                                                                                            #endif
                                                                                            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                                            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                                            #endif


                                                                                            // custom interpolator pre-include
                                                                                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                            // Includes
                                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                                            // --------------------------------------------------
                                                                                            // Structs and Packing

                                                                                            // custom interpolators pre packing
                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                            struct Attributes
                                                                                            {
                                                                                                 float3 positionOS : POSITION;
                                                                                                 float3 normalOS : NORMAL;
                                                                                                 float4 tangentOS : TANGENT;
                                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                 uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                #endif
                                                                                            };
                                                                                            struct Varyings
                                                                                            {
                                                                                                 float4 positionCS : SV_POSITION;
                                                                                                 float3 positionWS;
                                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                #endif
                                                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                #endif
                                                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                #endif
                                                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                #endif
                                                                                            };
                                                                                            struct SurfaceDescriptionInputs
                                                                                            {
                                                                                                 float3 WorldSpacePosition;
                                                                                                 float4 ScreenPosition;
                                                                                            };
                                                                                            struct VertexDescriptionInputs
                                                                                            {
                                                                                                 float3 ObjectSpaceNormal;
                                                                                                 float3 ObjectSpaceTangent;
                                                                                                 float3 ObjectSpacePosition;
                                                                                            };
                                                                                            struct PackedVaryings
                                                                                            {
                                                                                                 float4 positionCS : SV_POSITION;
                                                                                                 float3 interp0 : INTERP0;
                                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                #endif
                                                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                #endif
                                                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                #endif
                                                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                #endif
                                                                                            };

                                                                                            PackedVaryings PackVaryings(Varyings input)
                                                                                            {
                                                                                                PackedVaryings output;
                                                                                                ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                output.positionCS = input.positionCS;
                                                                                                output.interp0.xyz = input.positionWS;
                                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                output.instanceID = input.instanceID;
                                                                                                #endif
                                                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                #endif
                                                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                #endif
                                                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                output.cullFace = input.cullFace;
                                                                                                #endif
                                                                                                return output;
                                                                                            }

                                                                                            Varyings UnpackVaryings(PackedVaryings input)
                                                                                            {
                                                                                                Varyings output;
                                                                                                output.positionCS = input.positionCS;
                                                                                                output.positionWS = input.interp0.xyz;
                                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                output.instanceID = input.instanceID;
                                                                                                #endif
                                                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                #endif
                                                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                #endif
                                                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                output.cullFace = input.cullFace;
                                                                                                #endif
                                                                                                return output;
                                                                                            }


                                                                                            // --------------------------------------------------
                                                                                            // Graph

                                                                                            // Graph Properties
                                                                                            CBUFFER_START(UnityPerMaterial)
                                                                                            float2 _Position;
                                                                                            float _Size;
                                                                                            float _Smoothness;
                                                                                            float _Opacity;
                                                                                            CBUFFER_END

                                                                                                // Object and Global properties

                                                                                                // -- Property used by ScenePickingPass
                                                                                                #ifdef SCENEPICKINGPASS
                                                                                                float4 _SelectionID;
                                                                                                #endif

                                                                                            // -- Properties used by SceneSelectionPass
                                                                                            #ifdef SCENESELECTIONPASS
                                                                                            int _ObjectId;
                                                                                            int _PassValue;
                                                                                            #endif

                                                                                            // Graph Includes
                                                                                            // GraphIncludes: <None>

                                                                                            // Graph Functions

                                                                                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                                            {
                                                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                            }

                                                                                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A + B;
                                                                                            }

                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                            {
                                                                                                Out = UV * Tiling + Offset;
                                                                                            }

                                                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A - B;
                                                                                            }

                                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A / B;
                                                                                            }

                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A / B;
                                                                                            }

                                                                                            void Unity_Length_float2(float2 In, out float Out)
                                                                                            {
                                                                                                Out = length(In);
                                                                                            }

                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                            {
                                                                                                Out = 1 - In;
                                                                                            }

                                                                                            void Unity_Saturate_float(float In, out float Out)
                                                                                            {
                                                                                                Out = saturate(In);
                                                                                            }

                                                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                            {
                                                                                                Out = smoothstep(Edge1, Edge2, In);
                                                                                            }

                                                                                            // Custom interpolators pre vertex
                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                            // Graph Vertex
                                                                                            struct VertexDescription
                                                                                            {
                                                                                                float3 Position;
                                                                                                float3 Normal;
                                                                                                float3 Tangent;
                                                                                            };

                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                            {
                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                return description;
                                                                                            }

                                                                                            // Custom interpolators, pre surface
                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                            {
                                                                                            return output;
                                                                                            }
                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                            #endif

                                                                                            // Graph Pixel
                                                                                            struct SurfaceDescription
                                                                                            {
                                                                                                float Alpha;
                                                                                            };

                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                            {
                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                                                                float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                                                                float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                                                                Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                                                                float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                                                                Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                                                                float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                                                                Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                                                                float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                                                                Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                                                                float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                                                                Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                                                                float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                                                                float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                                                                float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                                                                Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                                                                float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                                                                float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                                                                Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                                                                float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                                                                Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                                                                float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                                                                Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                                                                float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                                                                Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                                                                float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                                                                Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                                                                float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                                                                float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                                                                Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                                                                float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                                Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                                                                surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                                return surface;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Build Graph Inputs

                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                            {
                                                                                                VertexDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                return output;
                                                                                            }
                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                            {
                                                                                                SurfaceDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                            #else
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                            #endif
                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                    return output;
                                                                                            }

                                                                                            void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                                                            {
                                                                                                result.vertex = float4(attributes.positionOS, 1);
                                                                                                result.tangent = attributes.tangentOS;
                                                                                                result.normal = attributes.normalOS;
                                                                                                result.vertex = float4(vertexDescription.Position, 1);
                                                                                                result.normal = vertexDescription.Normal;
                                                                                                result.tangent = float4(vertexDescription.Tangent, 0);
                                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                #endif
                                                                                            }

                                                                                            void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                                                            {
                                                                                                result.pos = varyings.positionCS;
                                                                                                result.worldPos = varyings.positionWS;
                                                                                                // World Tangent isn't an available input on v2f_surf


                                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                #endif
                                                                                                #if UNITY_SHOULD_SAMPLE_SH
                                                                                                #endif
                                                                                                #if defined(LIGHTMAP_ON)
                                                                                                #endif
                                                                                                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                                    result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                                                    COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                                                                #endif

                                                                                                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                                                            }

                                                                                            void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                                                            {
                                                                                                result.positionCS = surfVertex.pos;
                                                                                                result.positionWS = surfVertex.worldPos;
                                                                                                // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                                                                // World Tangent isn't an available input on v2f_surf

                                                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                #endif
                                                                                                #if UNITY_SHOULD_SAMPLE_SH
                                                                                                #endif
                                                                                                #if defined(LIGHTMAP_ON)
                                                                                                #endif
                                                                                                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                                    result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                                                    COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                                                                #endif

                                                                                                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Main

                                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                                                                            ENDHLSL
                                                                                            }
                                                                                            Pass
                                                                                            {
                                                                                                Name "ScenePickingPass"
                                                                                                Tags
                                                                                                {
                                                                                                    "LightMode" = "Picking"
                                                                                                }

                                                                                                // Render State
                                                                                                Cull Back

                                                                                                // Debug
                                                                                                // <None>

                                                                                                // --------------------------------------------------
                                                                                                // Pass

                                                                                                HLSLPROGRAM

                                                                                                // Pragmas
                                                                                                #pragma target 3.0
                                                                                                #pragma multi_compile_instancing
                                                                                                #pragma vertex vert
                                                                                                #pragma fragment frag

                                                                                                // DotsInstancingOptions: <None>
                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                // Keywords
                                                                                                // PassKeywords: <None>
                                                                                                // GraphKeywords: <None>

                                                                                                // Defines
                                                                                                #define _NORMALMAP 1
                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                #define SHADERPASS ScenePickingPass
                                                                                                #define BUILTIN_TARGET_API 1
                                                                                                #define SCENEPICKINGPASS 1
                                                                                                #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                                                                                #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                                                #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                                                #endif
                                                                                                #ifdef _BUILTIN_ALPHATEST_ON
                                                                                                #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                                                                #endif
                                                                                                #ifdef _BUILTIN_AlphaClip
                                                                                                #define _AlphaClip _BUILTIN_AlphaClip
                                                                                                #endif
                                                                                                #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                                                #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                                                #endif


                                                                                                // custom interpolator pre-include
                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                // Includes
                                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                                                // --------------------------------------------------
                                                                                                // Structs and Packing

                                                                                                // custom interpolators pre packing
                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                struct Attributes
                                                                                                {
                                                                                                     float3 positionOS : POSITION;
                                                                                                     float3 normalOS : NORMAL;
                                                                                                     float4 tangentOS : TANGENT;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct Varyings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                     float3 positionWS;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct SurfaceDescriptionInputs
                                                                                                {
                                                                                                     float3 WorldSpacePosition;
                                                                                                     float4 ScreenPosition;
                                                                                                };
                                                                                                struct VertexDescriptionInputs
                                                                                                {
                                                                                                     float3 ObjectSpaceNormal;
                                                                                                     float3 ObjectSpaceTangent;
                                                                                                     float3 ObjectSpacePosition;
                                                                                                };
                                                                                                struct PackedVaryings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                     float3 interp0 : INTERP0;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };

                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                {
                                                                                                    PackedVaryings output;
                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.interp0.xyz = input.positionWS;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }

                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                {
                                                                                                    Varyings output;
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.positionWS = input.interp0.xyz;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }


                                                                                                // --------------------------------------------------
                                                                                                // Graph

                                                                                                // Graph Properties
                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                float2 _Position;
                                                                                                float _Size;
                                                                                                float _Smoothness;
                                                                                                float _Opacity;
                                                                                                CBUFFER_END

                                                                                                    // Object and Global properties

                                                                                                    // -- Property used by ScenePickingPass
                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                    float4 _SelectionID;
                                                                                                    #endif

                                                                                                // -- Properties used by SceneSelectionPass
                                                                                                #ifdef SCENESELECTIONPASS
                                                                                                int _ObjectId;
                                                                                                int _PassValue;
                                                                                                #endif

                                                                                                // Graph Includes
                                                                                                // GraphIncludes: <None>

                                                                                                // Graph Functions

                                                                                                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                                                {
                                                                                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                                }

                                                                                                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                                                {
                                                                                                    Out = A + B;
                                                                                                }

                                                                                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                {
                                                                                                    Out = UV * Tiling + Offset;
                                                                                                }

                                                                                                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                                {
                                                                                                    Out = A * B;
                                                                                                }

                                                                                                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                                {
                                                                                                    Out = A - B;
                                                                                                }

                                                                                                void Unity_Divide_float(float A, float B, out float Out)
                                                                                                {
                                                                                                    Out = A / B;
                                                                                                }

                                                                                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                {
                                                                                                    Out = A * B;
                                                                                                }

                                                                                                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                                {
                                                                                                    Out = A / B;
                                                                                                }

                                                                                                void Unity_Length_float2(float2 In, out float Out)
                                                                                                {
                                                                                                    Out = length(In);
                                                                                                }

                                                                                                void Unity_OneMinus_float(float In, out float Out)
                                                                                                {
                                                                                                    Out = 1 - In;
                                                                                                }

                                                                                                void Unity_Saturate_float(float In, out float Out)
                                                                                                {
                                                                                                    Out = saturate(In);
                                                                                                }

                                                                                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                                {
                                                                                                    Out = smoothstep(Edge1, Edge2, In);
                                                                                                }

                                                                                                // Custom interpolators pre vertex
                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                // Graph Vertex
                                                                                                struct VertexDescription
                                                                                                {
                                                                                                    float3 Position;
                                                                                                    float3 Normal;
                                                                                                    float3 Tangent;
                                                                                                };

                                                                                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                {
                                                                                                    VertexDescription description = (VertexDescription)0;
                                                                                                    description.Position = IN.ObjectSpacePosition;
                                                                                                    description.Normal = IN.ObjectSpaceNormal;
                                                                                                    description.Tangent = IN.ObjectSpaceTangent;
                                                                                                    return description;
                                                                                                }

                                                                                                // Custom interpolators, pre surface
                                                                                                #ifdef FEATURES_GRAPH_VERTEX
                                                                                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                {
                                                                                                return output;
                                                                                                }
                                                                                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                #endif

                                                                                                // Graph Pixel
                                                                                                struct SurfaceDescription
                                                                                                {
                                                                                                    float Alpha;
                                                                                                };

                                                                                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                {
                                                                                                    SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                    float _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0 = _Smoothness;
                                                                                                    float4 _ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                    float2 _Property_07734e1dccbd494f9b3fec75d699ab33_Out_0 = _Position;
                                                                                                    float2 _Remap_09d774ec3a9344788187a461756c342a_Out_3;
                                                                                                    Unity_Remap_float2(_Property_07734e1dccbd494f9b3fec75d699ab33_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_09d774ec3a9344788187a461756c342a_Out_3);
                                                                                                    float2 _Add_123fee3565bb41ee96102189f9c1f091_Out_2;
                                                                                                    Unity_Add_float2((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), _Remap_09d774ec3a9344788187a461756c342a_Out_3, _Add_123fee3565bb41ee96102189f9c1f091_Out_2);
                                                                                                    float2 _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3;
                                                                                                    Unity_TilingAndOffset_float((_ScreenPosition_46e8c0fe1e7540bd8bbf2af551506b1b_Out_0.xy), float2 (1, 1), _Add_123fee3565bb41ee96102189f9c1f091_Out_2, _TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3);
                                                                                                    float2 _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2;
                                                                                                    Unity_Multiply_float2_float2(_TilingAndOffset_1c10a5dec3a749e2b6eb83182a90e8cf_Out_3, float2(2, 2), _Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2);
                                                                                                    float2 _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2;
                                                                                                    Unity_Subtract_float2(_Multiply_a4a12155d9e84f4eb1e055ce1f8fd3e0_Out_2, float2(1, 1), _Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2);
                                                                                                    float _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2;
                                                                                                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_9e66ff7c10924a23963248d3d6f49524_Out_2);
                                                                                                    float _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0 = _Size;
                                                                                                    float _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2;
                                                                                                    Unity_Multiply_float_float(_Divide_9e66ff7c10924a23963248d3d6f49524_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0, _Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2);
                                                                                                    float2 _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0 = float2(_Multiply_e7d7c87ee0d84fdd93f58b6a859712ba_Out_2, _Property_fb9b46b8c32b44c0bc834dc8909919b0_Out_0);
                                                                                                    float2 _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2;
                                                                                                    Unity_Divide_float2(_Subtract_8d5c8d4a1edd476ea03e8f2c5b8fb6ff_Out_2, _Vector2_1049772038f945f6a4dfa0d3f9efd763_Out_0, _Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2);
                                                                                                    float _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1;
                                                                                                    Unity_Length_float2(_Divide_f8a0c2c6aa444c049b18e6df9c6df3f4_Out_2, _Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1);
                                                                                                    float _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1;
                                                                                                    Unity_OneMinus_float(_Length_b0601ad4a59d4f6caeaa74aee9a3c64d_Out_1, _OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1);
                                                                                                    float _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1;
                                                                                                    Unity_Saturate_float(_OneMinus_bd126a28511e47729b2498c29bc6b017_Out_1, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1);
                                                                                                    float _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3;
                                                                                                    Unity_Smoothstep_float(0, _Property_ea7d50fd73cf46ada6eeb79002e83784_Out_0, _Saturate_f88d2b460b58426db5244808ff43bba1_Out_1, _Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3);
                                                                                                    float _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0 = _Opacity;
                                                                                                    float _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2;
                                                                                                    Unity_Multiply_float_float(_Smoothstep_596c77fd619447c393b582c69ea790a7_Out_3, _Property_c45753dbe9084f8f81258c37cf28d68c_Out_0, _Multiply_24e5fad6b686438a834d6803e200a52e_Out_2);
                                                                                                    float _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                                    Unity_OneMinus_float(_Multiply_24e5fad6b686438a834d6803e200a52e_Out_2, _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1);
                                                                                                    surface.Alpha = _OneMinus_8d34c621ef8d445dbc12f8e87a6148dc_Out_1;
                                                                                                    return surface;
                                                                                                }

                                                                                                // --------------------------------------------------
                                                                                                // Build Graph Inputs

                                                                                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                {
                                                                                                    VertexDescriptionInputs output;
                                                                                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                    output.ObjectSpaceNormal = input.normalOS;
                                                                                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                    output.ObjectSpacePosition = input.positionOS;

                                                                                                    return output;
                                                                                                }
                                                                                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                {
                                                                                                    SurfaceDescriptionInputs output;
                                                                                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                                                                                    output.WorldSpacePosition = input.positionWS;
                                                                                                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                #else
                                                                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                #endif
                                                                                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                        return output;
                                                                                                }

                                                                                                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                                                                {
                                                                                                    result.vertex = float4(attributes.positionOS, 1);
                                                                                                    result.tangent = attributes.tangentOS;
                                                                                                    result.normal = attributes.normalOS;
                                                                                                    result.vertex = float4(vertexDescription.Position, 1);
                                                                                                    result.normal = vertexDescription.Normal;
                                                                                                    result.tangent = float4(vertexDescription.Tangent, 0);
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    #endif
                                                                                                }

                                                                                                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                                                                {
                                                                                                    result.pos = varyings.positionCS;
                                                                                                    result.worldPos = varyings.positionWS;
                                                                                                    // World Tangent isn't an available input on v2f_surf


                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    #endif
                                                                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                                                                    #endif
                                                                                                    #if defined(LIGHTMAP_ON)
                                                                                                    #endif
                                                                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                                                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                                                                    #endif

                                                                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                                                                }

                                                                                                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                                                                {
                                                                                                    result.positionCS = surfVertex.pos;
                                                                                                    result.positionWS = surfVertex.worldPos;
                                                                                                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                                                                    // World Tangent isn't an available input on v2f_surf

                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    #endif
                                                                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                                                                    #endif
                                                                                                    #if defined(LIGHTMAP_ON)
                                                                                                    #endif
                                                                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                                                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                                                                    #endif

                                                                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                                                                }

                                                                                                // --------------------------------------------------
                                                                                                // Main

                                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                                                                                ENDHLSL
                                                                                                }
                                                                    }
                                                                        CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInLitGUI" ""
                                                                                                    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                                                    FallBack "Hidden/Shader Graph/FallbackError"
}