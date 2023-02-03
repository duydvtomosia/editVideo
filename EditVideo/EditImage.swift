//
//  AdjustImage.swift
//  EditVideo
//
//  Created by tomosia on 02/02/2023.
//

import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import MetalPetal
import Photos
import UIKit

enum EditType: String, CaseIterable {
    case adjust
    case filter
}

enum FilterType: CaseIterable {
    case original
    case fade
    case mono
    case noir

    var name: String {
        switch self {
        case .original:
            return "Original"
        case .fade:
            return "Fade"
        case .mono:
            return "Mono"
        case .noir:
            return "Noir"
        }
    }

    var identifier: String {
        switch self {
        case .original:
            return "Original"
        case .fade:
            return "CIPhotoEffectFade"
        case .mono:
            return "CIPhotoEffectMono"
        case .noir:
            return "CIPhotoEffectNoir"
        }
    }
}

enum AdjustType: CaseIterable {
    case exposure
    case highlights
    case shadows
    case contrast
    case brightness
    case saturation

    var name: String {
        switch self {
        case .exposure: return "Exposure"
        case .saturation: return "Saturation"
        case .brightness: return "Brightness"
        case .contrast: return "Contrast"
        case .shadows: return "Shadows"
        case .highlights: return "Highlights"
        }
    }

    var image: String {
        switch self {
        case .exposure: return "ic_exposure"
        case .saturation: return "ic_saturation"
        case .brightness: return "ic_brightness"
        case .contrast: return "ic_contrast"
        case .shadows: return "ic_shadows"
        case .highlights: return "ic_highlights"
        }
    }
}

class FilteredImage: Equatable {
    static func == (lhs: FilteredImage, rhs: FilteredImage) -> Bool {
        lhs.image == rhs.image
    }

    var image: UIImage
    var mtiImage: MTIImage?
    let customFilter = MTICustomFilter()
    var mtiBlendFilter = MTIBlendFilter(blendMode: .normal)
    var filter: FilterType

    init(image: UIImage, filter: FilterType) {
        self.image = image
        self.filter = filter
        mtiImage = MTIImage(ciImage: CIImage(image: image)!).unpremultiplyingAlpha()
        customFilter.inputImage = mtiImage
    }
}

class EditImage {
    static let shared = EditImage()

    private var inputImage = UIImage()

    var isImageAvailable: Bool {
        return inputImage != UIImage()
    }

    var listFilteredImage: [FilteredImage] = []

    private let context = CIContext()
    let device = MTLCreateSystemDefaultDevice()
    let options = MTIContextOptions()
    private var mtiContext: MTIContext?

    private var contrastValue: Float = 0.0 {
        didSet {
            listFilteredImage.forEach { filteredImage in
                filteredImage.customFilter.contrast = 1 + contrastValue / 2
            }
        }
    }

    private var brightnessValue: Float = 0.0 {
        didSet {
            listFilteredImage.forEach { filteredImage in
                filteredImage.customFilter.brightness = brightnessValue / 2
            }
        }
    }

    private var saturationValue: Float = 0.0 {
        didSet {
            listFilteredImage.forEach { filteredImage in
                filteredImage.customFilter.saturation = 1 + saturationValue
            }
        }
    }

    private var exposureValue: Float = 0.0 {
        didSet {
            listFilteredImage.forEach { filteredImage in
                filteredImage.customFilter.exposure = exposureValue
            }
        }
    }

    private var highlightValue: Float = 0.0 {
        didSet {
            listFilteredImage.forEach { filteredImage in
                let filter = CIFilter.highlightShadowAdjust()
                filter.inputImage = filteredImage.image.toCIImage()
                filter.highlightAmount = highlightValue
            }
        }
    }

    private var shadowValue: Float = 0.0 {
        didSet {
            listFilteredImage.forEach { _ in

            }
        }
    }

    func setInputImage(_ image: UIImage, isAdded: Bool = false) {
        inputImage = image

        listFilteredImage = FilterType.allCases.map { filter in
            FilteredImage(image: filterImage(inputImage,
                                             filter: filter).resize(to: CGSize(width: 720, height: 720)),
                          filter: filter)
        }
        mtiContext = try? MTIContext(device: device!, options: options)
    }

    func adjust(
        type: AdjustType,
        input: Float,
        filter: FilterType,
        completion: @escaping (UIImage) -> Void
    ) {
        switch type {
        case .brightness:
            brightnessValue = input
            break
        case .contrast:
            contrastValue = input
            break
        case .saturation:
            saturationValue = input
            break
        case .exposure:
            exposureValue = input
            break
        case .highlights:
            highlightValue = input
            break
        case .shadows:
            shadowValue = input
            break
        }
        guard !listFilteredImage.isEmpty,
              let outputImage = exportImage(type: type,
                                            filteredImage: listFilteredImage
                                                .first(where: { $0.filter == filter })),
              let cgImage = try? mtiContext?.makeCGImage(from: outputImage)
        else { return }
        DispatchQueue.main.async {
            completion(UIImage(cgImage: cgImage))
        }
    }

    func filterImage(_ input: UIImage, filter: FilterType) -> UIImage {
        if filter != FilterType.original {
            guard let filter = CIFilter(name: filter.identifier),
                  let ciImage = CIImage(image: input) else { return input }
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            guard let filteredImage = filter.outputImage,
                  let cgImage = context.createCGImage(filteredImage,
                                                      from: filteredImage.extent)
            else { return input }
            return UIImage(cgImage: cgImage)
        }
        return input
    }

    func applyAdjustAndEffectToImage(filter: FilterType, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
            guard let ciImage = CIImage(image: self.inputImage) else { return }
            let mtiImage = MTIImage(ciImage: ciImage).unpremultiplyingAlpha()
            let customFilter = MTICustomFilter()
            customFilter.inputImage = mtiImage
            customFilter.contrast = 1 + self.contrastValue / 2
            customFilter.brightness = self.brightnessValue / 2
            customFilter.saturation = 1 + self.saturationValue
            customFilter.exposure = 0.5 + self.exposureValue
            guard let outputImage = customFilter.outputImage,
                  let cgImage = try? self.mtiContext?.makeCGImage(from: outputImage)
            else { return }
            let image = UIImage(cgImage: cgImage)
            if filter != .original {
                let filter = CIFilter(name: filter.identifier)
                filter?.setValue(image, forKey: kCIInputImageKey)
                guard let outputImage = filter?.outputImage,
                      let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent)
                else { return }
                completion(UIImage(cgImage: cgImage))
            } else {
                completion(image)
            }
        }
    }

    func applyAdjustAndEffectToVideo(
        _ input: URL,
        filter: FilterType,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let asset = AVAsset(url: input)
        let composition = AVVideoComposition(asset: asset) { request in
            var source = request.sourceImage.clampedToExtent()
            let mtiImage = MTIImage(ciImage: source).unpremultiplyingAlpha()
            let customFilter = MTICustomFilter()
            customFilter.inputImage = mtiImage
            customFilter.contrast = 1 + self.contrastValue / 2
            customFilter.brightness = self.brightnessValue / 2
            customFilter.saturation = 1 + self.saturationValue
            customFilter.exposure = 0.5 + self.exposureValue
            source = customFilter.outputImage
                .map({ try? self.mtiContext?.makeCGImage(from: $0) })?
                .map({ CIImage(cgImage: $0) }) ?? source
//            if self.shadowValue != 0.0 ||
//                self.highlightValue != 0.0 {
//                let highlightShadow = CIFilter.highlightShadowAdjust()
//                highlightShadow.inputImage = source
//                highlightShadow.highlightAmount = 1 + self.highlightValue
//                highlightShadow.shadowAmount = self.shadowValue
//                source = highlightShadow.outputImage!.cropped(to: request.sourceImage.extent)
//            }
            if filter != FilterType.original {
                guard let filter = CIFilter(name: filter.identifier) else { return }
                filter.setValue(source, forKey: kCIInputImageKey)
                source = filter.outputImage!.cropped(to: request.sourceImage.extent)
            }
            request.finish(with: source, context: nil)
        }
        try? FileManager.default.removeItem(atPath: input.path)
        let avAssetExportSession = AVAssetExportSession(asset: asset,
                                                        presetName: AVAssetExportPresetHighestQuality)
        avAssetExportSession?.outputURL = input
        avAssetExportSession?.outputFileType = .mp4
        avAssetExportSession?.videoComposition = composition
        avAssetExportSession?.exportAsynchronously {
            switch avAssetExportSession?.status {
            case .failed:
                completion(false, avAssetExportSession?.error)
            case .completed:
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: (avAssetExportSession?.outputURL)!)
                }) { saved, _ in
                    completion(saved, nil)
                }
            default: break
            }
        }
    }

//    func changeFilter(type: AdjustType) {
//        listFilteredImage.forEach { image in
//            image.customFilter.inputImage = image.mtiImage
//            switch type {
//            case .brightness, .saturation, .contrast:
//                image.colorControls.inputImage = image.image.toCIImage()
//            case .exposure:
//                image.exposureAdjust.inputImage = image.image.toCIImage()
//            case .highlights, .shadows:
//                image.highlightShadow.inputImage = image.image.toCIImage()
//            }
//        }
//    }
//
    func exportImage(type: AdjustType, filteredImage: FilteredImage?) -> MTIImage? {
        guard let filteredImage = filteredImage else { return nil }
        switch type {
        case .exposure, .contrast, .brightness, .saturation:
            return filteredImage.customFilter.outputImage
        case .highlights, .shadows:
            return filteredImage.mtiBlendFilter.outputImage
        }
    }

    func getInformation(of type: AdjustType) -> Float {
        switch type {
        case .exposure: return exposureValue
        case .brightness: return brightnessValue
        case .contrast: return contrastValue
        case .saturation: return saturationValue
        case .highlights: return highlightValue
        case .shadows: return shadowValue
        }
    }

    func resetFilter() {
        contrastValue = 0.0
        brightnessValue = 0.0
        saturationValue = 0.0
        highlightValue = 0.0
        shadowValue = 0.0
        exposureValue = 0.0
    }
}
