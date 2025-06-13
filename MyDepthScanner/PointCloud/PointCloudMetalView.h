/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view implementing point cloud rendering
*/


#ifndef MetalImageDraw_h
#define MetalImageDraw_h

#import <MetalKit/MetalKit.h>
#import <CoreVideo/CoreVideo.h>
#import <AVFoundation/AVDepthData.h>
#import <ARKit/ARKit.h>

@interface PointCloudMetalView : MTKView

// Public buffer for pointcloud
@property (nonatomic, assign) NSUInteger pointNumber;
@property (nonatomic, strong) id<MTLBuffer> pointCloudBuffer;

// Update depth frame
- (void)setDepthFrame:(AVDepthData* _Nonnull)depth withTexture:(_Nonnull CVPixelBufferRef)unormTexture;

// Rotate around the Y axis
- (void)yawAroundCenter:(float)angle;

// Rotate around the X axis
- (void)pitchAroundCenter:(float)angle;

// Rotate around the Z axis
- (void)rollAroundCenter:(float)angle;

// Moves the camera towards the center point (or backwards)
- (void)moveTowardCenter:(float)scale;

// Resets translation, rotation and zoom
- (void)resetView;


@end


#endif /* MetalImageDraw_h */
