//
//  AdjustImage.swift
//  EditVideo
//
//  Created by tomosia on 02/02/2023.
//

import AVFoundation
import Combine
import CoreImage
import CoreImage.CIFilterBuiltins
import MetalPetal
import Photos
import UIKit

class FilteredImage: Equatable {
    static func == (lhs: FilteredImage, rhs: FilteredImage) -> Bool {
        lhs.image == rhs.image
    }

    var image: UIImage
    var filter: FilterType

    init(image: UIImage, filter: FilterType) {
        self.image = image
        self.filter = filter
    }
}

class EditImage {
    static let shared = EditImage()

    var inputImage = CIImage()

    var isImageAvailable: Bool {
        return inputImage != UIImage()
    }

    var listFilteredImage: [FilteredImage] = []
    var filter: FilterType = .original

    private let context = CIContext()

    private var contrastValue: Float = 0.0
    private var brightnessValue: Float = 0.0
    private var saturationValue: Float = 0.0
    private var exposureValue: Float = 0.0
    private var highlightValue: Float = 0.0
    private var shadowValue: Float = 0.0
    private var vibranceValue: Float = 0.0
    private var temperatureValue: Float = 0.0
    private var hslValue: Float = 0.0
    private var vignetteValue: Float = 0.0
    private var sharpenValue: Float = 0.0
    private var hueValue: Float = 0.0
    private var noiseReductionValue: Float = 0.0

    func setInputImage(_ image: UIImage, isAdded: Bool = false) {
        inputImage = image.toCIImage()
    }

    func adjust(
        type: AdjustType,
        input: Float,
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
        case .vibrance:
            vibranceValue = input
            break
        case .temperature:
            temperatureValue = input
            break
        case .hsl:
            hslValue = input
            break
        case .vignette:
            vignetteValue = input
            break
        case .sharpen:
            sharpenValue = input
            break
        case .hue:
            hueValue = input
            break
        case .noiseReduction:
            noiseReductionValue = input
            break
        }
        completion(adjustImage(inputImage, type: filter).toUIImage())
    }

    func getInformation(of type: AdjustType) -> Float {
        switch type {
        case .exposure: return exposureValue
        case .brightness: return brightnessValue
        case .contrast: return contrastValue
        case .saturation: return saturationValue
        case .highlights: return highlightValue
        case .shadows: return shadowValue
        case .vibrance: return vibranceValue
        case .temperature: return temperatureValue
        case .hsl: return hslValue
        case .vignette: return vignetteValue
        case .sharpen: return sharpenValue
        case .hue: return hueValue
        case .noiseReduction: return noiseReductionValue
        }
    }

    func exportVideo(_ input: URL, completion: @escaping (Bool, Error?) -> Void) {
        let asset = AVAsset(url: input)
        let videoComposition = AVVideoComposition(asset: asset) { [weak self] request in
            guard let self = self else { return }
            let source = self.adjustImage(request.sourceImage.clampedToExtent(), type: self.filter)
            request.finish(with: source, context: nil)
        }

        let avAssetExportSession = AVAssetExportSession(asset: asset,
                                                        presetName: AVAssetExportPresetHighestQuality)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("outputVideo.mp4")

        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(atPath: outputURL.path)
        }
        avAssetExportSession?.videoComposition = videoComposition
        avAssetExportSession?.outputURL = outputURL
        avAssetExportSession?.outputFileType = .mp4

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

    func resetFilter() {
        contrastValue = 0.0
        brightnessValue = 0.0
        saturationValue = 0.0
        highlightValue = 0.0
        shadowValue = 0.0
        exposureValue = 0.0
        vibranceValue = 0.0
        temperatureValue = 0.0
        hslValue = 0.0
        vignetteValue = 0.0
        sharpenValue = 0.0
        hueValue = 0.0
        noiseReductionValue = 0.0
    }

    func adjustImage(_ input: CIImage, type: FilterType) -> CIImage {
        return filterImage(input, type: type)
            .applyingFilter(CIFilter.colorControls().name,
                            parameters: [kCIInputContrastKey: 1 + contrastValue / 5,
                                       kCIInputBrightnessKey: brightnessValue / 2,
                                         kCIInputSaturationKey: 1 + saturationValue])
            .applyingFilter(CIFilter.exposureAdjust().name,
                            parameters: [kCIInputEVKey: 0.5 + exposureValue * 2])
            .applyingFilter(CIFilter.highlightShadowAdjust().name,
                            parameters: ["inputHighlightAmount": 1 + highlightValue,
                                         "inputShadowAmount": shadowValue])
            .applyingFilter(CIFilter.vibrance().name, parameters: [kCIInputAmountKey: vibranceValue])
            .applyingFilter(CIFilter.temperatureAndTint().name, parameters: ["inputNeutral": CIVector(x: CGFloat(temperatureValue * 1000) + 6500)])
            .applyingFilter(CIFilter.vignette().name, parameters: [kCIInputIntensityKey: vignetteValue])
            .applyingFilter(CIFilter.sharpenLuminance().name, parameters: [kCIInputSharpnessKey: 0.4 + sharpenValue * 0.6])
            .applyingFilter(CIFilter.hueAdjust().name, parameters: [kCIInputAngleKey: hueValue])
            .applyingFilter(CIFilter.noiseReduction().name, parameters: ["inputNoiseLevel": -noiseReductionValue])
    }

    func filterImage(_ input: CIImage, type: FilterType) -> CIImage {
        switch type {
        case .original:
            return input
        case .vivid:
            return applyVividFilter(to: input)
        case .vividWarm:
            return applyVividWarmFilter(to: input)
        case .vividCool:
            return applyVividCoolFilter(to: input)
        case .dramatic:
            return applyDramaticFilter(to: input)
        case .dramaticWarm:
            return applyDramaticWarmFilter(to: input)
        case .dramaticCool:
            return applyDramaticCoolFilter(to: input)
        case .mono:
            return applyMonoFilter(to: input)
        case .silverStone:
            return applySilverstoneFilter(to: input)
        case .noir:
            return applyNoirFilter(to: input)
        }
    }

    func applyVividFilter(to image: CIImage) -> CIImage {
        // Convert UIImage to CIImage

        // Apply the Color Controls filter to increase saturation and contrast
        let outputImage = image
            .applyingFilter(CIFilter.colorControls().name, parameters: [kCIInputContrastKey: 2,
                                                                        kCIInputSaturationKey: 2,
                                                                        kCIInputBrightnessKey: 0.4])

        return outputImage
    }

    func applyDramaticFilter(to image: CIImage) -> CIImage {
        return image
            .applyingFilter(CIFilter.highlightShadowAdjust().name, parameters: ["inputHighlightAmount": 1,
                                                                                "inputShadowAmount": 0.0])
    }

    func applyVividWarmFilter(to image: CIImage) -> CIImage {
        // Apply the temperature adjustment filter
        let temperatureFilter = CIFilter(name: "CITemperatureAndTint")
        temperatureFilter?.setValue(image, forKey: kCIInputImageKey)
        temperatureFilter?.setValue(CIVector(x: 8000, y: 0), forKey: "inputNeutral")

        guard let temperatureOutput = temperatureFilter?.outputImage else {
            return inputImage
        }
        return applyVividFilter(to: temperatureOutput)
    }

    func applyVividCoolFilter(to image: CIImage) -> CIImage {
        // Apply the temperature adjustment filter
        let temperatureFilter = CIFilter(name: "CITemperatureAndTint")
        temperatureFilter?.setValue(image, forKey: kCIInputImageKey)
        temperatureFilter?.setValue(CIVector(x: 5000, y: 0), forKey: "inputNeutral")

        guard let temperatureOutput = temperatureFilter?.outputImage else {
            return inputImage
        }
        return applyVividFilter(to: temperatureOutput)
    }

    func applyDramaticWarmFilter(to image: CIImage) -> CIImage {
        // Apply the temperature adjustment filter
        let temperatureFilter = CIFilter(name: "CITemperatureAndTint")
        temperatureFilter?.setValue(image, forKey: kCIInputImageKey)
        temperatureFilter?.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
        temperatureFilter?.setValue(CIVector(x: 5000, y: 0), forKey: "inputTargetNeutral")

        guard let temperatureOutput = temperatureFilter?.outputImage else {
            return inputImage
        }
        return applyDramaticFilter(to: temperatureOutput)
    }

    func applyDramaticCoolFilter(to image: CIImage) -> CIImage {
        // Apply the temperature adjustment filter
        let temperatureFilter = CIFilter(name: "CITemperatureAndTint")
        temperatureFilter?.setValue(image, forKey: kCIInputImageKey)
        temperatureFilter?.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
        temperatureFilter?.setValue(CIVector(x: 10000, y: 0), forKey: "inputTargetNeutral")

        guard let temperatureOutput = temperatureFilter?.outputImage else {
            return inputImage
        }
        return applyDramaticFilter(to: temperatureOutput)
    }

    func applySilverstoneFilter(to image: CIImage) -> CIImage {
        // Apply Sepia Tone filter
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(image, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(0.6, forKey: kCIInputIntensityKey)

        // Apply Fade filter
        let fadeFilter = CIFilter(name: "CIPhotoEffectFade")
        fadeFilter?.setValue(sepiaFilter?.outputImage, forKey: kCIInputImageKey)

        // Render the filtered CIImage into a CGImage
        guard let outputImage = fadeFilter?.outputImage else {
            return image
        }

        return outputImage
    }

    func applyMonoFilter(to image: CIImage) -> CIImage {
        return image.applyingFilter(CIFilter.photoEffectMono().name, parameters: [:])
    }

    func applyNoirFilter(to image: CIImage) -> CIImage {
        return image.applyingFilter(CIFilter.photoEffectNoir().name, parameters: [:])
    }
}
