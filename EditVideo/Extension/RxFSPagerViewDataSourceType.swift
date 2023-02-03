//
//  RxFSPagerViewDataSourceTyoe.swift
//  EditVideo
//
//  Created by tomosia on 24/02/2023.
//

import FSPagerView
import RxSwift
import UIKit

/// Marks data source as 'FSPagerView' reactice data source enabling it to be used with one of the 'bindTo' methods
public protocol RxFSPagerViewDataSourceType {
    associatedtype Element

    /// New observable seqeuence event observed
    ///
    /// - parameter pagerView: Bound pager view
    /// - parameter observedEvent: Event
    func pagerView(_ pagerView: FSPagerView, observedEvent: Event<Element>)
}
