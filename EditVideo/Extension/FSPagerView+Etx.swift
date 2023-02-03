//
//  FSPagerView.swift
//  EditVideo
//
//  Created by tomosia on 28/02/2023.
//

import FSPagerView
import UIKit

extension FSPagerView {
    func registerCell<T: FSPagerViewCell>(aClass: T.Type) {
        let className = String(describing: aClass)
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellWithReuseIdentifier: className)
    }

    func dequeueReusableCell<T: FSPagerViewCell>(aClass: T.Type, index: Int) -> T {
        let className = String(describing: aClass)
        guard let cell = dequeueReusableCell(withReuseIdentifier: className, at: index) as? T else {
            fatalError("\(className) is not register")
        }
        return cell
    }
}
