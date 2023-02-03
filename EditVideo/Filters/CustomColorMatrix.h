//
//  CustomColorMatrx.h
//  EditVideo
//
//  Created by tomosia on 10/02/2023.
//

#import <Foundation/Foundation.h>
#import "MTIShaderLib.h"

FOUNDATION_EXPORT const MTIColorMatrix CustomColorMatrixIdentity NS_SWIFT_NAME(MTIColorMatrix.identity);
FOUNDATION_EXPORT const MTIColorMatrix ColorMatrixRGBColorInvert NS_SWIFT_NAME(MTIColorMatrix.rgbColorInvert);

FOUNDATION_EXPORT BOOL ColorMatrixEqualToColorMatrix(MTIColorMatrix a, MTIColorMatrix b) NS_SWIFT_NAME(MTIColorMatrix.isEqual(self:to:));
FOUNDATION_EXPORT BOOL ColorMatrixIsIdentity(MTIColorMatrix matrix) NS_SWIFT_NAME(getter:MTIColorMatrix.isIdentity(self:));

FOUNDATION_EXPORT MTIColorMatrix ColorMatrixConcat(MTIColorMatrix a, MTIColorMatrix b) NS_SWIFT_NAME(MTIColorMatrix.concat(self:with:));

FOUNDATION_EXPORT MTIColorMatrix ColorMatrixMakeWithExposure(MTIColorMatrix m, float exposure, float contrast) NS_SWIFT_NAME(MTIColorMatrix.init(self:exposure:contrast:));
FOUNDATION_EXPORT MTIColorMatrix ColorMatrixMakeWithSaturation(MTIColorMatrix m, float saturation, simd_float3 grayColorTransform) NS_SWIFT_NAME(MTIColorMatrix.init(self:saturation:grayColorTransform:));
FOUNDATION_EXPORT MTIColorMatrix ColorMatrixMakeWithBrightness(MTIColorMatrix m, float brightness, float contrast) NS_SWIFT_NAME(MTIColorMatrix.init(self:brightness:contrast:));
FOUNDATION_EXPORT MTIColorMatrix ColorMatrixMakeWithContrast(MTIColorMatrix m, float contrast, float brightness, float exposure) NS_SWIFT_NAME(MTIColorMatrix.init(self:contrast:brightness:exposure:));
FOUNDATION_EXPORT MTIColorMatrix ColorMatrixMakeWithOpacity(MTIColorMatrix m, float opacity) NS_SWIFT_NAME(MTIColorMatrix.init(self:opacity:));
