//
//  ViewController.swift
//  EditVideo
//
//  Created by tomosia on 31/01/2023.
//

import AVFoundation
import FSPagerView
import Photos
import PhotosUI
import RxCocoa
import RxSwift
import UIKit

class ViewController: UIViewController {
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var rulerControlView: UIView!
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
    @IBOutlet var slider: UISlider!

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
                .adjustImage(EditImage.shared.inputImage, type: currentFilter)
            let attribute = listFilter
                .first(where: { self.currentFilter == $0 })
                .map { $0.name }
            EditImage.shared.filter = currentFilter
            attributeNameTextField.text = attribute
            imageView.image = filteredImage.toUIImage()
        }
    }

    var currentAdjust = AdjustType.exposure {
        didSet {
            attributeNameTextField.text = currentAdjust.name
            slider.value = Float(EditImage.shared.getInformation(of: currentAdjust) * 100).rounded()
        }
    }

    let imageSize = CGSize(width: 80.0, height: 80.0)
    private let sliderValue = PublishSubject<Float>()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupPagerView()
        attributeNameTextField.text = listAdjust.first?.name

        sliderValue
            .asObservable()
            .map { Float($0 / 100).rounded(toPlaces: 1) }
            .distinctUntilChanged()
            .debounce(.milliseconds(100), scheduler: MainScheduler())
            .subscribe { [weak self] value in
                guard let self = self else { return }
                EditImage.shared.adjust(type: self.currentAdjust,
                                        input: value) { image in
                    DispatchQueue.main.async {
                        self.filterPagerView.reloadData()
                        self.adjustPagerView.reloadData()
                        self.imageView.image = image
                    }
                }
            }
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
            .just(listFilter.map { $0.name })
            .bind(to: filterPagerView.rx.items) { pagerView, row, _ in
                let cell = pagerView.dequeueReusableCell(aClass: FilterTypeCell.self, index: row)
                cell.filterName.text = self.listFilter[row].name
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
                        self.currentFilter.name == filterType.name
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
                    return
                }
                EditImage.shared.exportVideo(videoUrl) { isSaved, error in
                    DispatchQueue.main.async {
                        ProgressHUD.dismiss()
                        guard let error = error,
                              !isSaved else {
                            self.showAlert(title: "Saved!", message: "Your video has been saved to your Photos")
                            return
                        }
                        self.showAlert(title: "Error!", message: error.localizedDescription)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    func setupPagerView() {
        filterPagerView.registerCell(aClass: FilterTypeCell.self)
        filterPagerView.transformer = FSPagerViewTransformer(type: .linear)
        filterPagerView.itemSize = CGSize(width: 128, height: 64)

        adjustPagerView.registerCell(aClass: AdjustTypeCell.self)
        adjustPagerView.transformer = FSPagerViewTransformer(type: .linear)
        adjustPagerView.itemSize = CGSize(width: 64, height: 64)
    }

    func showImagePickerView() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .videos

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
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

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        sliderValue.onNext(sender.value)
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let result = results.first else { return }
        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
            if let error = error {
                return
            }
            guard let self = self,
                  let url = url else { return }
            let newFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("inputVideo.mp4")
            if FileManager.default.fileExists(atPath: newFileURL.path) {
                try? FileManager.default.removeItem(at: newFileURL)
            }
            try? FileManager.default.copyItem(at: url, to: newFileURL)
            let thumbnail = self.thumbnailForVideoAtURL(newFileURL) ?? UIImage()
            EditImage.shared.setInputImage(thumbnail)
            self.originalSize = thumbnail.size
            self.videoUrl = newFileURL
            DispatchQueue.main.async {
                self.imageView.image = thumbnail
            }
        }
    }
}
