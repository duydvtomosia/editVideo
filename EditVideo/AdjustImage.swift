//
//  AdjustImage.swift
//  EditVideo
//
//  Created by tomosia on 02/02/2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

class AdjustImage {
    static let shared = AdjustImage()

    var targetImage = UIImage()
    let context = CIContext()
    let colorControls = CIFilter.colorControls()
    let exposureAdjust = CIFilter.exposureAdjust()

    func colorControl(type: AdjustType, input: CGFloat) {
        colorControls.inputImage = CIImage(image: targetImage)
        switch type {
        case .brightness:
            colorControls.brightness = Float(input)
            break
        case .contrast:
            colorControls.contrast = Float(input)
            break
        case .saturation:
            colorControls.saturation = Float(input)
            break
        default: break
        }
        guard let outputImage = colorControls.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else { return }
        targetImage = UIImage(cgImage: cgImage)
    }
}
