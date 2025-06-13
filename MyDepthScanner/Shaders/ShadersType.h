//
//  ShadersType.h
//  MyDepthScanner
//
//  Created by Yohanes Sugiarto on 31/05/24.
//

#ifndef ShadersType_h
#define ShadersType_h

#include <simd/simd.h>

struct TestParticle {
    int number;
};

typedef struct {
    vector_float3 position;
    float depth;
} PointData;

//enum TextureIndices {
//    kTextureY = 0,
//    kTextureCbCr = 1,
//    kTextureDepth = 2,
//    kTextureConfidence = 3
//};
//
//enum BufferIndices {
//    kPointCloudUniforms = 0,
//    kParticleUniforms = 1,
//    kGridPoints = 2,
//};
//
//struct PointCloudUniforms {
//    matrix_float4x4 viewProjectionMatrix;
//    matrix_float4x4 localToWorld;
//    matrix_float3x3 cameraIntrinsicsInversed;
//    simd_float2 cameraResolution;
//    
//    float particleSize;
//    int maxPoints;
//    int pointCloudCurrentIndex;
//    int confidenceThreshold;
//};
//
//struct ParticleUniforms {
//    simd_float3 position;
//    simd_float3 color;
//    float confidence;
//};

#endif /* ShadersType_h */
