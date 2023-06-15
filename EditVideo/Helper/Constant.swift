//
//  Constant.swift
//  EditVideo
//
//  Created by tomosia on 09/06/2023.
//

import Foundation

enum EditType: String, CaseIterable {
    case adjust
    case filter
}

enum FilterType: CaseIterable {
    case original
    case vivid
    case vividWarm
    case vividCool
    case dramatic
    case dramaticWarm
    case dramaticCool
    case mono
    case silverStone
    case noir

    var name: String {
        switch self {
        case .original:
            return "Original"
        case .vivid:
            return "Vivid"
        case .vividWarm:
            return "Vivid warm"
        case .vividCool:
            return "Vivid cool"
        case .dramatic:
            return "Dramatic"
        case .dramaticWarm:
            return "Dramatic warm"
        case .dramaticCool:
            return "Dramatic cool"
        case .mono:
            return "Mono"
        case .silverStone:
            return "Silver stone"
        case .noir:
            return "Noir"
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
    case vibrance
    case temperature
    case hsl
    case vignette
    case sharpen
    case hue
    case noiseReduction

    var name: String {
        switch self {
        case .exposure: return "Exposure"
        case .saturation: return "Saturation"
        case .brightness: return "Brightness"
        case .contrast: return "Contrast"
        case .shadows: return "Shadows"
        case .highlights: return "Highlights"
        case .vibrance: return "Vibrance"
        case .temperature: return "Temperature"
        case .hsl: return "HSL"
        case .vignette: return "Vignette"
        case .sharpen: return "Sharpen"
        case .hue: return "Hue"
        case .noiseReduction: return "Noise reduction"
        }
    }

    var image: String {
        switch self {
        case .exposure: return"ic_exposure"
        case .saturation: return"ic_saturation"
        case .brightness: return "ic_brightness"
        case .contrast: return "ic_contrast"
        case .shadows: return "ic_shadows"
        case .highlights: return "ic_highlights"
        case .vibrance: return "ic_highlights"
        case .temperature: return "ic_highlights"
        case .hsl: return "ic_highlights"
        case .vignette: return "ic_highlights"
        case .sharpen: return "ic_highlights"
        case .hue: return "ic_highlights"
        case .noiseReduction: return "ic_highlights"
        }
    }
}
