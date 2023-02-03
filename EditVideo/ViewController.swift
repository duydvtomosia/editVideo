//
//  ViewController.swift
//  EditVideo
//
//  Created by tomosia on 31/01/2023.
//

import AVFoundation
import CRRulerControl
import FSPagerView
import RxCocoa
import RxSwift
import UIKit
import YPImagePicker

class ViewController: UIViewController {
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var rulerControlView: CRRulerControl!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var adjustImageView: UIImageView!
    @IBOutlet var filterImageView: UIImageView!
    @IBOutlet var filterPagerView: FSPagerView!
    @IBOutlet var adjustPagerView: FSPagerView!
    @IBOutlet var attributeNameTextField: UITextField!
    @IBOutlet var addPhotoButton: UIButton!
    @IBOutlet var adjustButton: UIButton!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var doneButton: UIButton!

    var editType: EditType = EditType.adjust {
        didSet {
            titleTextField.text = editType.rawValue.uppercased()
            adjustPagerView.isHidden = editType == .filter
            rulerControlView.isHidden = editType == .filter
            adjustImageView.tintColor = editType == .adjust ? UIColor.systemBlue : UIColor.gray
            filterImageView.tintColor = editType == .filter ? UIColor.systemBlue : UIColor.gray
            attributeNameTextField.text = editType == .filter
                ? currentFilter.name
                : currentAdjust.name
        }
    }

    let listFilter: [FilterType] = FilterType.allCases
    let listAdjust: [AdjustType] = AdjustType.allCases
    var originalSize = CGSize.zero
    var videoUrl: URL?

    var currentFilter = FilterType.original {
        didSet {
            let filteredImage = EditImage
                .shared
                .listFilteredImage
                .first { $0.filter == self.currentFilter }
                .map { $0.image }
            let attribute = listFilter
                .first(where: { self.currentFilter == $0 })
                .map { $0.name }

            attributeNameTextField.text = attribute
            imageView.image = filteredImage
        }
    }

    var currentAdjust = AdjustType.exposure {
        didSet {
            attributeNameTextField.text = currentAdjust.name
            rulerControlView.value = CGFloat(EditImage.shared.getInformation(of: currentAdjust) * 100).rounded()
        }
    }

    let imageSize = CGSize(width: 80.0, height: 80.0)
    private let numberOfRuler = PublishSubject<Float>()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupRulerControl()
        setupPagerView()
        attributeNameTextField.text = listAdjust.first?.name

        rulerControlView
            .scrollView
            .rx
            .didScroll
            .asDriver()
            .map { _ in
                Float(self.rulerControlView.value / 100).rounded(toPlaces: 1)
            }
            .distinctUntilChanged()
            .debounce(.milliseconds(100))
            .drive(onNext: { [weak self] value in
                guard let self = self else { return }
                DispatchQueue.global().async {
                    EditImage.shared.adjust(type: self.currentAdjust,
                                            input: value,
                                            filter: self.currentFilter) { image in
                        DispatchQueue.main.async {
                            self.filterPagerView.reloadData()
                            self.adjustPagerView.reloadData()
                            self.imageView.image = image
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        addPhotoButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showImagePickerView()
            })
            .disposed(by: disposeBag)

        filterPagerView
            .rx
            .didSelectItem
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.currentFilter = self.listFilter[index]
                self.filterPagerView.deselectItem(at: index, animated: false)
                self.filterPagerView.scrollToItem(at: index, animated: true)
            })
            .disposed(by: disposeBag)

        filterPagerView
            .rx
            .willEndDragging
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.currentFilter = self.listFilter[index]
            })
            .disposed(by: disposeBag)

        _ = Observable
            .from(listFilter.map { $0.name })
            .bind(to: filterPagerView.rx.items) { pagerView, row, _ in
                let cell = pagerView.dequeueReusableCell(aClass: FilterTypeCell.self, index: row)

                if !EditImage.shared.listFilteredImage.isEmpty {
                    cell.contentImageView.image = EditImage
                        .shared
                        .listFilteredImage[row]
                        .image
                        .resize(to: CGSize(width: 128, height: 128))
                }
                return cell
            }
            .disposed(by: disposeBag)

        adjustPagerView
            .rx
            .didSelectItem
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.currentAdjust = self.listAdjust[index]
                self.adjustPagerView.deselectItem(at: index, animated: false)
                self.adjustPagerView.scrollToItem(at: index, animated: true)
            })
            .disposed(by: disposeBag)

        adjustPagerView
            .rx
            .willEndDragging
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.currentAdjust = self.listAdjust[index]
            })
            .disposed(by: disposeBag)

        _ = Observable
            .just(listAdjust.map { $0.name })
            .bind(to: adjustPagerView.rx.items) { pagerView, row, _ in
                let cell = pagerView.dequeueReusableCell(aClass: AdjustTypeCell.self, index: row)

                cell.contentImageView.image = UIImage(named: self.listAdjust[row].image)
                cell.isEditedView.isHidden = EditImage.shared.getInformation(of: self.listAdjust[row]) == 0.0
                return cell
            }

        adjustButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { _ in
                if self.editType == .filter {
                    self.editType = .adjust
                    self.attributeNameTextField.text = self.currentAdjust.name
                }
            }).disposed(by: disposeBag)

        filterButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { _ in
                if self.editType == .adjust {
                    self.editType = .filter
                    let attribute = self.listFilter.first(where: { filterType in
                        self.currentFilter.identifier == filterType.identifier
                    }).map({ filter in
                        filter.name
                    })
                    self.attributeNameTextField.text = attribute
                }
            }).disposed(by: disposeBag)

        doneButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                ProgressHUD.show()
                guard let videoUrl = self.videoUrl else {
                    EditImage
                        .shared
                        .applyAdjustAndEffectToImage(filter: self.currentFilter) { image in
                            UIImageWriteToSavedPhotosAlbum(image,
                                                           self,
                                                           #selector(self.saveImage(_: didFinishSavingWithError: contextInfo:)),
                                                           nil)
                        }
                    return
                }
                EditImage
                    .shared
                    .applyAdjustAndEffectToVideo(videoUrl, filter: self.currentFilter) { isSaved, error in
                        ProgressHUD.dismiss()
                        guard let error = error,
                              isSaved else {
                            self.showAlert(title: "Saved!", message: "Your video has been saved to your Photos")
                            return
                        }
                        self.showAlert(title: "Error!", message: error.localizedDescription)
                    }
            })
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !EditImage.shared.isImageAvailable {
            showImagePickerView()
        }
    }

    func setupRulerControl() {
        rulerControlView.isHidden = editType == .filter
        rulerControlView.rangeFrom = -100
        rulerControlView.rangeLength = 200
        rulerControlView.setFrequency(50, for: .major)
        rulerControlView.setFrequency(10, for: .minor)
        rulerControlView.spacingBetweenMarks = 20
    }

    func setupPagerView() {
        filterPagerView.registerCell(aClass: FilterTypeCell.self)
        filterPagerView.transformer = FSPagerViewTransformer(type: .linear)
        filterPagerView.itemSize = imageSize

        adjustPagerView.registerCell(aClass: AdjustTypeCell.self)
        adjustPagerView.transformer = FSPagerViewTransformer(type: .linear)
        adjustPagerView.itemSize = CGSize(width: 64, height: 64)
    }

    func showImagePickerView() {
        var config = YPImagePickerConfiguration()
        config.hidesCancelButton = !EditImage.shared.isImageAvailable
        config.screens = [.library]
        config.library.mediaType = .photoAndVideo
        config.showsPhotoFilters = false
        config.showsVideoTrimmer = false
        let imagePickerView = YPImagePicker(configuration: config)

        imagePickerView.didFinishPicking { [unowned imagePickerView] items, _ in
            if let photo = items.singlePhoto {
                EditImage.shared.setInputImage(photo.image)
                self.originalSize = photo.image.size
                self.imageView.image = photo.image
            }
            if let video = items.singleVideo {
                let thumbnail = self.thumbnailForVideoAtURL(video.url) ?? UIImage()
                EditImage.shared.setInputImage(thumbnail)
                self.originalSize = thumbnail.size
                self.videoUrl = video.url
                self.imageView.image = thumbnail
            }
            EditImage.shared.resetFilter()
            self.filterPagerView.reloadData()
            imagePickerView.dismiss(animated: true, completion: nil)
        }
        present(imagePickerView, animated: true, completion: nil)
    }

    private func thumbnailForVideoAtURL(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }

    @objc func saveImage(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        ProgressHUD.dismiss()
        if let error = error {
            showAlert(title: "Error!", message: error.localizedDescription)
        } else {
            showAlert(title: "Saved!", message: "Your image has been saved to your Photos")
        }
    }

    func showAlert(title: String, message: String?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
