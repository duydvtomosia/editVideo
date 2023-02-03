//
//  CustomFilter.m
//  EditVideo
//
//  Created by tomosia on 09/02/2023.
//

#import "CustomColorMatrix.h"
#import "CustomFilter.h"
#import "MTIFunctionDescriptor.h"
#import "MTIImage.h"
#import "MTIKernel.h"
#import "MTIRenderPipelineKernel.h"
#import "CoreImage/CIFilter.h"

NSString *const MTIColorMatrixFilterColorMatrixParameterKey = @"colorMatrix";

@implementation MTICustomFilter

- (instancetype)init {
    if (self = [super init]) {
        self.contrast = 1;
        self.grayColorTransform = MTIGrayColorTransformDefault;
        self.saturation = 1;
        self.colorMatrix = MTIColorMatrixIdentity;
        self.exposure = 0.5;
    }

    return self;
}

- (void)setExposure:(float)exposure {
    _exposure = exposure;
    [super setColorMatrix:ColorMatrixMakeWithExposure(self.colorMatrix, exposure, _contrast)];
}

- (void)setSaturation:(float)saturation {
    _saturation = saturation;
    [super setColorMatrix:ColorMatrixMakeWithSaturation(self.colorMatrix, self.saturation, self.grayColorTransform)];
}

- (void)setGrayColorTransform:(simd_float3)grayColorTransform {
    _grayColorTransform = grayColorTransform;
    [super setColorMatrix:ColorMatrixMakeWithSaturation(self.colorMatrix, self.saturation, self.grayColorTransform)];
}

- (void)setBrightness:(float)brightness {
    _brightness = brightness;
    [super setColorMatrix:ColorMatrixMakeWithBrightness(self.colorMatrix, brightness, _contrast)];
}

- (void)setContrast:(float)contrast {
    _contrast = contrast;
    [super setColorMatrix:ColorMatrixMakeWithContrast(self.colorMatrix, contrast, _brightness, _exposure)];
}

- (void)setHighlights:(float)highlights {
    _highlights = highlights;
    
}

@end
