-- Copyright (C) 2008-2017 Christoph Kubisch. All rights reserved.
---------------------------------------------------------

local funccall = "([A-Za-z_][A-Za-z0-9_]*)%s*"

if not CMarkSymbols then dofile "spec/cbase.lua" end
return {
  exts = {"glsl","vert","frag","geom","cont","eval", "glslv", "glslf"},
  lexer = wxstc.wxSTC_LEX_CPP,
  apitype = "glsl",
  sep = ".",
  linecomment = "//",
  
  isfncall = function(str)
    return string.find(str, funccall .. "%(")
  end,

  marksymbols = CMarkSymbols,

  lexerstyleconvert = {
    text = {wxstc.wxSTC_C_IDENTIFIER,},

    lexerdef = {wxstc.wxSTC_C_DEFAULT,},
    comment = {wxstc.wxSTC_C_COMMENT,
      wxstc.wxSTC_C_COMMENTLINE,
      wxstc.wxSTC_C_COMMENTDOC,},
    stringtxt = {wxstc.wxSTC_C_STRING,
      wxstc.wxSTC_C_CHARACTER,
      wxstc.wxSTC_C_VERBATIM,},
    stringeol = {wxstc.wxSTC_C_STRINGEOL,},
    preprocessor= {wxstc.wxSTC_C_PREPROCESSOR,},
    operator = {wxstc.wxSTC_C_OPERATOR,},
    number = {wxstc.wxSTC_C_NUMBER,},

    keywords0 = {wxstc.wxSTC_C_WORD,},
    keywords1 = {wxstc.wxSTC_C_WORD2,},
  },

  keywords = 
  { 
    [[
    int uint half float bool double
    vec2 vec3 vec4 dvec2 dvec3 dvec4
    ivec2 ivec3 ivec4 uvec2 uvec3 uvec4 bvec2 bvec3 bvec4
    mat2 mat3 mat4 mat2x2 mat3x3 mat4x4 mat2x3 mat3x2 mat4x2 mat2x4 mat4x3 mat3x4
    dmat2 dmat3 dmat4 dmat2x2 dmat3x3 dmat4x4 dmat2x3 dmat3x2 dmat4x2 dmat2x4 dmat4x3 dmat3x4
    struct void
    subroutine
    
    float16_t f16vec2 f16vec3 f16vec4
    float32_t f32vec2 f32vec3 f32vec4
    float64_t f64vec2 f64vec3 f64vec4
    int8_t i8vec2 i8vec3 i8vec4
    int8_t i8vec2 i8vec3 i8vec4
    int16_t i16vec2 i16vec3 i16vec4
    int32_t i32vec2 i32vec3 i32vec4
    int64_t i64vec2 i64vec3 i64vec4
    uint8_t u8vec2 u8vec3 u8vec4
    uint16_t u16vec2 u16vec3 u16vec4
    uint32_t u32vec2 u32vec3 u32vec4
    uint64_t u64vec2 u64vec3 u64vec4
    
    main
    attribute const uniform varying buffer shared
    coherent volatile restrict readonly writeonly
    atomic_uint
    layout 
    centroid flat smooth noperspective
    patch sample
    break continue do for while switch case default
    if else
    subroutine
    in out inout
    float double int void bool true false
    invariant precise
    discard return
    lowp mediump highp precision
    buffer_reference buffer_reference_align
    
    location vertices line_strip triangle_strip max_vertices stream index
    triangles quads equal_spacing isolines fractional_even_spacing lines points
    fractional_odd_spacing cw ccw point_mode lines_adjacency triangles_adjacency
    invocations offset align xfb_offset xfb_buffer
    origin_upper_left pixel_center_integer depth_greater depth_greater depth_greater depth_unchanged
    shared packed std140 std430 row_major column_major
    local_size_x local_size_y local_size_z
    early_fragment_tests
        
    post_depth_coverage
    bindless_sampler bound_sampler bindless_image bound_image
    binding set input_attachment_index
    pixel_interlock_ordered pixel_interlock_unordered sample_interlock_ordered sample_interlock_unordered
    passthrough push_constant secondary_view_offset viewport_relative override_coverage
    commandBindableNV
    subgroupuniformEXT
    scalar
   
    size1x8 size1x16 size1x32 size2x32 size4x32 rgba32f rgba16f rg32f rg16f r32f r16f rgba8 rgba16 r11f_g11f_b10f rgb10_a2ui
    rgb10_a2i rg16 rg8 r16 r8 rgba32i rgba16i rgba8i rg32i rg16i rg8i r32i r16i r8i rgba32ui rgba16ui rgba8ui rg32ui rg16ui rg8ui
    r32ui r16ui r8ui rgba16_snorm rgba8_snorm rg16_snorm rg8_snorm r16_snorm r8_snorm

    subpassInput isubpassInput usubpassInput
    subpassInputMS isubpassInputMS usubpassInputMS
    
    sampler 
    samplerShadow 
    
    sampler1DShadow sampler2DShadow sampler2DRectShadow samplerCubeShadow sampler1DArrayShadow sampler2DArrayShadow samplerCubeArrayShadow
    
    image1D image2D image3D image2DRect imageCube imageBuffer image1DArray image2DArray imageCubeArray image2DMS image2DMSArray
    uimage1D uimage2D uimage3D uimage2DRect uimageCube uimageBuffer uimage1DArray uimage2DArray uimageCubeArray uimage2DMS uimage2DMSArray
    iimage1D iimage2D iimage3D iimage2DRect iimageCube iimageBuffer iimage1DArray iimage2DArray iimageCubeArray iimage2DMS iimage2DMSArray
    
    texture1D texture2D texture3D textureCube texture2DRect texture1DArray texture2DArray textureBuffer texture2DMS texture2DMSArray textureCubeArray
    utexture1D utexture2D utexture3D utextureCube utexture2DRect utexture1DArray utexture2DArray utextureBuffer utexture2DMS utexture2DMSArray utextureCubeArray
    itexture1D itexture2D itexture3D itextureCube itexture2DRect itexture1DArray itexture2DArray itextureBuffer itexture2DMS itexture2DMSArray itextureCubeArray
    
    usampler1D usampler2D usampler3D usampler2DRect usamplerBuffer usamplerCube isampler1DArray usampler2DARRAY usamplerCubeArray usampler2DMS usampler2DMSArray
    isampler1D isampler2D isampler3D isampler2DRect isamplerCube isamplerBuffer isampler1DArray isampler2DARRAY isamplerCubeArray isampler2DMS isampler2DMSArray
    sampler1D sampler2D sampler3D sampler2DRect samplerCube samplerBuffer sampler1DArray sampler2DArray samplerCubeArray sampler2DMS sampler2DMSArray
    
    gl_Position gl_FragCoord
    gl_VertexID gl_InstanceID gl_PointSize gl_ClipDistance
    gl_TexCoord gl_FogFragCoord gl_ClipVertex gl_in gl_out gl_PerVertex
    gl_PatchVerticesIn
    gl_PrimitiveID gl_InvocationID gl_TessLevelOuter gl_TessLevelInner gl_TessCoord
    gl_InvocationID gl_PrimitiveIDIn gl_Layer gl_ViewportIndex gl_FrontFacing
    gl_PointCoord gl_SampleID gl_SamplePosition gl_FragColor
    gl_FragData gl_FragDepth gl_SampleMask
    gl_NumWorkGroups gl_WorkGroupSize gl_WorkGroupID gl_LocalInvocationID gl_GlobalInvocationID gl_LocalInvocationIndex
    gl_HelperInvocation gl_CullDistance
    gl_VertexIndex gl_InstanceIndex
    
    gl_BaseVertexARB gl_BaseInstanceARB gl_DrawIDARB
    gl_DrawID
    
    gl_SubGroupInvocationARB gl_SubGroupEqMaskARB gl_SubGroupGeMaskARB gl_SubGroupGtMaskARB gl_SubGroupLeMaskARB gl_SubGroupLtMaskARB
    gl_SubGroupSizeARB
    
    gl_ViewportMask
    gl_SecondaryPositionNV gl_SecondaryViewportMaskNV
    gl_ThreadInWarpNV gl_ThreadEqMaskNV gl_ThreadGeMaskNV gl_ThreadGtMaskNV gl_ThreadLeMaskNV gl_ThreadLtMaskNV gl_WarpIDNV gl_SMIDNV gl_HelperThreadNV
    gl_WarpSizeNV gl_WarpsPerSMNV gl_WarpsPerSMNV
    
    gl_NumSubgroups gl_SubgroupID gl_SubgroupSize gl_SubgroupInvocationID 
    gl_SubgroupEqMask gl_SubgroupGeMask gl_SubgroupGtMask gl_SubgroupLeMask gl_SubgroupLtMask
    
    gl_TaskCountNV gl_PrimitiveCountNV gl_PrimitiveIndicesNV 
    gl_ClipDistancePerViewNV gl_PositionPerViewNV gl_CullDistancePerViewNV gl_LayerPerViewN gl_ViewportMaskPerViewNV
    gl_MaxMeshViewCountNV
    gl_MeshViewCountNV gl_MeshViewIndicesNV gl_MeshPerVertexNV gl_MeshPerPrimitiveNV
    gl_MeshVerticesNV gl_MeshPrimitivesNV
    perprimitiveNV perviewNV taskNV
    max_primitives
    
    accelerationStructureNV
    rayPayloadNV rayPayloadInNV hitAttributeNV callableDataNV callableDataInNV 
    shaderRecordNV
    gl_LaunchIDNV gl_LaunchSizeNV gl_InstanceCustomIndexNV
    gl_WorldRayOriginNV gl_WorldRayDirectionNV gl_ObjectRayOriginNV gl_ObjectRayDirectionNV
    gl_RayTminNV gl_RayTmaxNV gl_IncomingRayFlagsNV gl_HitTNV gl_HitKindNV
    gl_ObjectToWorldNV gl_WorldToObjectNV
    gl_RayFlagsNoneNV
    gl_RayFlagsOpaqueNV
    gl_RayFlagsNoOpaqueNV
    gl_RayFlagsTerminateOnFirstHitNV
    gl_RayFlagsSkipClosestHitShaderNV
    gl_RayFlagsCullBackFacingTrianglesNV
    gl_RayFlagsCullFrontFacingTrianglesNV
    gl_RayFlagsCullOpaqueNV
    gl_RayFlagsCullNoOpaqueNV

    gl_FragmentSizeNV gl_InvocationsPerPixelNV
    shading_rate_interlock_ordered shading_rate_interlock_unordered
    
    pervertexNV
    gl_BaryCoordNV
    gl_BaryCoordNoPerspNV
    
    derivative_group_quadsNV derivative_group_linearNV
    
    nonuniformEXT

    gl_FragSizeEXT
    gl_FragInvocationCountEXT

    gl_ScopeDevice
    gl_ScopeWorkgroup
    gl_ScopeSubgroup
    gl_ScopeInvocation
    gl_ScopeQueueFamily

    gl_SemanticsRelaxed
    gl_SemanticsAcquire
    gl_SemanticsRelease
    gl_SemanticsAcquireRelease
    gl_SemanticsMakeAvailable
    gl_SemanticsMakeVisible

    gl_StorageSemanticsNone
    gl_StorageSemanticsBuffer
    gl_StorageSemanticsShared
    gl_StorageSemanticsImage
    gl_StorageSemanticsOutput
    
    common partition active asm class union enum typedef template this resource goto 
    noinline inline public static private extern external interface long short half fixed unsigned superp
    input output filter sizeof cast namespace using 
    ]],

    [[
    radians degrees sin cos tan asin acos atan sinh cosh tanh asinh acosh atanh
    pow exp log exp2 log2 sqrt inversesqrt abs sign floor trunc round
    roundEven ceil fract mod modf min max mix step isnan isinf clamp smoothstep
    fma frexp ldexp
    
    floatBitsToInt floatBitsToUint intBitsToFloat uintBitsToFloat 
    doubleBitsToInt64 doubleBitsToUint64 int64BitsToDouble uint64BitsToDouble
    
    packUnorm2x16 packUnorm4x8 packSnorm4x8
    unpackUnorm2x16 unpackUnorm4x8 unpackSnorm4x8
    packDouble2x32 unpackDouble2x32
    packHalf2x16 unpackHalf2x16
    packInt2x32 packUint2x32 unpackInt2x32 unpackUint2x32
    packFloat2x16 unpackFloat2x16 

    length distance dot cross normalize ftransform faceforward
    reflect refract
    matrixCompMult outerProduct transpose determinant inverse
    lessThan lessThanEqual greaterThan greaterThanEqual equal
    notEqual any all not
    uaddCarry usubBorrow umulExtended imulExtended
    bitfeldExtract bitfieldInsert bitfeldReverse bitCount
    findLSB findMSB
    dFdx dFdy fwidth dFdxFine dFdyFine fwidthFine dFdxCoarse dFdyCoarse fwidthCoarse
    interpolateAtCentroid interpolateAtSample interpolateAtOffset
    noise1 noise2 noise3 noise4
    
    EmitStreamVertex EndStreamPrimitive EmitVertex EndPrimitive
    
    textureSize textureSamples textureQueryLod textureQueryLevels
    texture textureOffset textureProj
    textureLod textureProjOffset textureLodOffset
    texelFetchOffset texelFetch textureProjLod textureProjLodOffset
    textureGrad textureGradOffset textureProjGrad textureProjGradOffset
    textureGather textureGatherOffset textureGatherOffsets

    imageLoad imageStore
    imageAtomicAdd imageAtomicMin imageAtomicMax
    imageAtomicIncWrap imageAtomicDecWrap imageAtomicAnd
    imageAtomicOr imageAtomixXor imageAtomicExchange
    imageAtomicCompSwap imageSize imageSamples
    
    subpassLoad
    
    barrier
    memoryBarrier groupMemoryBarrier memoryBarrierAtomicCounter memoryBarrierShared memoryBarrierBuffer memoryBarrierImage
    
    atomicCounterIncrement atomicCounterDecrement atomicCounter
    atomicMin atomicMax atomicAdd atomicAnd atomicOr atomicXor atomicExchange atomicCompSwap
    
    anyInvocationARB allInvocationsARB allInvocationsEqualARB
    
    packPtr unpackPtr
    anyThreadNV allThreadsNV allThreadsEqualNV
    activeThreadsNV ballotThreadNV
    quadSwizzle0NV quadSwizzle1NV quadSwizzle2NV quadSwizzle3NV
    quadSwizzleXNV quadSwizzleYNV
    shuffleDownNV shuffleUpNV shuffleXorNV shuffleNV
    
    ballotARB readInvocationARB readFirstInvocationARB
    clock2x32ARB clockARB
    
    sparseTexelsResidentARB
    sparseTextureARB sparseTextureLodARB sparseTextureOffsetARB sparseTexelFetchARB 
    sparseTexelFetchOffsetARB sparseTextureLodOffsetARB sparseTextureGradARB 
    sparseTextureGradOffsetARB sparseTextureGatherARB sparseTextureGatherOffsetARB sparseTextureGatherOffsetsARB
    sparseImageLoadARB
    sparseTextureClampARB sparseTextureOffsetClampARB  sparseTextureGradClampARB  sparseTextureGradOffsetClampARB
    textureClampARB textureOffsetClampARB textureGradClampARB textureGradOffsetClampARB
    
    subgroupBarrier subgroupMemoryBarrier subgroupMemoryBarrierBuffer subgroupMemoryBarrierShared subgroupMemoryBarrierImage
    subgroupElect subgroupAll subgroupAny subgroupAllEqual
    subgroupBroadcast subgroupBroadcastFirst subgroupBallot subgroupInverseBallot
    subgroupBallotBitExtract subgroupBallotBitCount subgroupBallotInclusiveBitCount subgroupBallotExclusiveBitCount 
    subgroupBallotFindLSB subgroupBallotFindMSB
    subgroupShuffle subgroupShuffleXor subgroupShuffleUp subgroupShuffleDown
    subgroupAdd subgroupMul subgroupMin subgroupMax subgroupAnd subgroupOr subgroupXor
    subgroupInclusiveAdd subgroupInclusiveMul subgroupInclusiveMin subgroupInclusiveMax subgroupInclusiveAnd subgroupInclusiveOr subgroupInclusiveXor
    subgroupExclusiveAdd subgroupExclusiveMul subgroupExclusiveMin subgroupExclusiveMax subgroupExclusiveAnd subgroupExclusiveOr subgroupExclusiveXor
    subgroupClusteredAdd subgroupClusteredMul subgroupClusteredMin subgroupClusteredMax subgroupClusteredAnd subgroupClusteredOr subgroupClusteredXor
    subgroupQuadBroadcast subgroupQuadSwapHorizontal subgroupQuadSwapVertical subgroupQuadSwapDiagonal
    
    writePackedPrimitiveIndices4x8NV
    
    traceNV reportIntersectionNV ignoreIntersectionNV terminateRayNV executeCallableNV 
    
    textureFootprintNV
    textureFootprintClampNV
    textureFootprintLodNV
    textureFootprintGradNV
    textureFootprintGradClampNV

    subgroupPartitionNV
    subgroupPartitionedAddNV subgroupPartitionedMulNV subgroupPartitionedMinNV subgroupPartitionedMaxNV
    subgroupPartitionedAndNV subgroupPartitionedOrNV subgroupPartitionedXorNV
    subgroupPartitionedInclusiveAddNV subgroupPartitionedInclusiveMulNV subgroupPartitionedInclusiveMinNV subgroupPartitionedInclusiveMaxNV
    subgroupPartitionedInclusiveAndNV subgroupPartitionedInclusiveOrNV subgroupPartitionedInclusiveXorNV
    subgroupPartitionedExclusiveAddNV subgroupPartitionedExclusiveMulNV subgroupPartitionedExclusiveMinNV subgroupPartitionedExclusiveMaxNV
    subgroupPartitionedExclusiveAndNV subgroupPartitionedExclusiveOrNV subgroupPartitionedExclusiveXorNV
  ]],

  },
}
