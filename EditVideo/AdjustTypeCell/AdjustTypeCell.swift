//
//  AdjustTypeCell.swift
//  EditVideo
//
//  Created by tomosia on 02/02/2023.
//

import FSPagerView
import UIKit

class AdjustTypeCell: FSPagerViewCell {
    @IBOutlet var borderView: UIView!
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var isEditedView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.frame = borderView.bounds
        shapeLayer.fillColor = nil
        shapeLayer.path = UIBezierPath(rect: borderView.bounds).cgPath
        shapeLayer.masksToBounds = true
        shapeLayer.lineWidth = 2
        borderView.layer.addSublayer(shapeLayer)
    }
}
