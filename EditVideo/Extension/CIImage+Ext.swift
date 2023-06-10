//
//  CIImage.swift
//  EditVideo
//
//  Created by tomosia on 09/06/2023.
//

import CoreImage
import Foundation
import UIKit

extension CIImage {
    func toUIImage() -> UIImage {
        let context: CIContext = CIContext(options: nil)
        guard let cgImage: CGImage = context.createCGImage(self, from: extent) else { return UIImage() }
        let image: UIImage = UIImage(cgImage: cgImage)
        return image
    }
}
