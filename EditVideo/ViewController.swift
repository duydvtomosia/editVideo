//
//  ViewController.swift
//  EditVideo
//
//  Created by tomosia on 31/01/2023.
//

import CRRulerControl
import FSPagerView
import UIKit
import YPImagePicker

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

class ViewController: UIViewController {
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var rulerControlView: CRRulerControl!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var editTypeImageView: UIImageView!
    @IBOutlet var filterPagerView: FSPagerView!
    @IBOutlet var adjustPagerView: FSPagerView!
    @IBOutlet var attributeNameTextField: UITextField!

    var editType: EditType = EditType.adjust {
        didSet {
            titleTextField.text = editType.rawValue.uppercased()
            adjustPagerView.isHidden = editType == .filter
        }
    }

    let listFilter: [FilterType] = FilterType.allCases
    let listAdjust: [AdjustType] = AdjustType.allCases
    var image = UIImage() {
        didSet {
            attributeNameTextField.isHidden = image == UIImage()
            attributeNameTextField.text = editType == .filter ? currentFilter : currentAdjust?.name
            imageView.image = image
            filterPagerView.reloadData()
        }
    }

    var currentFilter = FilterType.original.identifier {
        didSet {
            guard let ciImage = CIImage(image: image),
                  let filteredImage = filterImage(ciImage,
                                                  filter: currentFilter)?.resize(to: CGSize(width: 720,
                                                                                            height: 720)),
                  let attribute = listFilter.first(where: { filterType in
                      currentFilter == filterType.identifier
                  }).map({ filter in
                      filter.name
                  })
            else { return }
            attributeNameTextField.text = attribute
            imageView.image = filteredImage
        }
    }

    var currentAdjust: AdjustType? {
        didSet {
            guard let type = currentAdjust else { return }
            attributeNameTextField.text = type.name
            switch type {
            case .contrast, .brightness, .saturation:
                AdjustImage.shared.colorControl(type: type, input: rulerControlView.value)
                break
            default: break
            }
        }
    }

    let context = CIContext(options: nil)
    let imageSize = CGSize(width: 80.0, height: 80.0)
    var imagePickerView = YPImagePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupRulerControl()
        setupPagerView()
        configImagePickerView()
        attributeNameTextField.isHidden = true
    }

    func setupRulerControl() {
        rulerControlView.isHidden = editType == .filter
        rulerControlView.rangeFrom = 0
        rulerControlView.rangeLength = 100
        rulerControlView.setFrequency(25, for: .major)
        rulerControlView.setFrequency(1, for: .middle)
        rulerControlView.spacingBetweenMarks = 10
        rulerControlView.value = 100
    }

    func setupPagerView() {
        filterPagerView.delegate = self
        filterPagerView.dataSource = self
        filterPagerView.register(UINib(nibName: "FilterTypeCell", bundle: nil),
                                 forCellWithReuseIdentifier: "filterTypeCell")
        filterPagerView.transformer = FSPagerViewTransformer(type: .linear)
        filterPagerView.itemSize = imageSize

        adjustPagerView.delegate = self
        adjustPagerView.dataSource = self
        adjustPagerView.register(UINib(nibName: "AdjustTypeCell", bundle: nil),
                                 forCellWithReuseIdentifier: "adjustTypeCell")
        adjustPagerView.itemSize = CGSize(width: 64, height: 64)
    }

    func configImagePickerView() {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.library.mediaType = .photo
        imagePickerView = YPImagePicker(configuration: config)
    }

    func filterImage(_ input: CIImage, filter: String) -> UIImage? {
        if filter != FilterType.original.identifier {
            let filter = CIFilter(name: filter)
            filter?.setValue(input, forKey: kCIInputImageKey)
            guard let filteredImage = filter?.outputImage,
                  let cgImage = context.createCGImage(filteredImage,
                                                      from: filteredImage.extent)
            else { return nil }
            return UIImage(cgImage: cgImage)
        }
        return image
    }

    @IBAction func valueChanged(_ sender: CRRulerControl) {
    }

    @IBAction func didTapAddPhotoButton(_ sender: Any) {
        imagePickerView.didFinishPicking { [unowned imagePickerView] items, _ in
            if let photo = items.singlePhoto {
                self.image = photo.image
            }
            imagePickerView.dismiss(animated: true, completion: nil)
        }
        present(imagePickerView, animated: true, completion: nil)
    }

    @IBAction func didTapEditTypeButton(_ sender: Any) {
    }
}

extension ViewController: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        if pagerView == filterPagerView {
            currentFilter = listFilter[index].identifier
        } else {
            currentAdjust = listAdjust[index]
        }
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        if pagerView == filterPagerView {
            currentFilter = listFilter[targetIndex].identifier
        } else {
            currentAdjust = listAdjust[targetIndex]
        }
    }
}

extension ViewController: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return pagerView == filterPagerView ? listFilter.count : listAdjust.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        if pagerView == filterPagerView {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "filterTypeCell", at: index) as! FilterTypeCell
            let targetImage = image.resize(to: imageSize).toCIImage()
            if let filteredImage = filterImage(targetImage, filter: listFilter[index].identifier) {
                cell.contentImageView.image = filteredImage
            }
            return cell
        } else {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "adjustTypeCell", at: index) as! AdjustTypeCell
            cell.contentImageView.image = UIImage(named: listAdjust[index].image)
            return cell
        }
    }
}
