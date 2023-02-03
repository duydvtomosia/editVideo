//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "MTIColorMatrix.h"
#import "MTIColorMatrixFilter.h"
#import "MTIFilter.h"
#import "MTIUnaryImageRenderingFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTICustomFilter : MTIColorMatrixFilter

@property (nonatomic) float exposure;
@property (nonatomic) float saturation;
@property (nonatomic) simd_float3 grayColorTransform;
@property (nonatomic) float brightness;
@property (nonatomic) float contrast;
@property (nonatomic) float highlights;
@property (nonatomic) float shadows;

- (void)setColorMatrix:(MTIColorMatrix)colorMatrix NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
