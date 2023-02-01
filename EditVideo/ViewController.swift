//
//  ViewController.swift
//  EditVideo
//
//  Created by tomosia on 31/01/2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import CRRulerControl
import FSPagerView
import UIKit

enum EditType: CaseIterable {
    case adjust
    case filter

    var image: UIImage {
        switch self {
        case .filter:
            return UIImage(named: "ic_filter")!
        case .adjust:
            return UIImage(named: "ic_adjust")!
        }
    }
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

class ViewController: UIViewController {
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var rulerControlView: CRRulerControl!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var popUpButton: UIButton!
    @IBOutlet var editTypeImageView: UIImageView!
    @IBOutlet var previewFSPagerView: FSPagerView!

    let editTypes: [EditType] = EditType.allCases
    let listFilter: [FilterType] = FilterType.allCases
    let image = UIImage(named: "Image")
    var currentFilter: String? {
        didSet {
            guard let ciImage = CIImage(image: image ?? UIImage()),
                  let filteredImage = filterImage(ciImage, intensity: currentIntensity)
            else { return }
            imageView.image = filteredImage
        }
    }

    var currentIntensity: Double = 1.0
    let context = CIContext(options: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupRulerControl()

        imageView.image = image

        popUpButton.menu = UIMenu(
            options: .displayInline,
            children: listFilter.map({ filter in
                UIAction(title: filter.name, handler: handle)
            }))
    }

    @objc func handle(_ action: UIAction) {
        currentFilter = listFilter.first(where: { filterType in
            filterType.name == action.title
        }).map({ filterType in
            filterType.identifier
        })
    }

    func setupRulerControl() {
        rulerControlView.rangeFrom = 0
        rulerControlView.rangeLength = 100
        rulerControlView.setFrequency(25, for: .major)
        rulerControlView.setFrequency(1, for: .middle)
        rulerControlView.spacingBetweenMarks = 10
        rulerControlView.value = 100
    }

    func filterImage(_ input: CIImage, intensity: Double) -> UIImage? {
        if currentFilter != FilterType.original.identifier {
            let filter = CIFilter(name: currentFilter ?? "")
            filter?.setValue(input, forKey: kCIInputImageKey)
            guard let filteredImage = filter?.outputImage,
                  let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent)
            else { return nil }
            return UIImage(cgImage: cgImage)
        }
        return image
    }

    @IBAction func valueChanged(_ sender: CRRulerControl) {
//        currentIntensity = sender.value / 100.0
    }
}

extension ViewController: FSPagerViewDelegate {
    
}

extension ViewController: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return listFilter.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        <#code#>
    }
    
    
}
