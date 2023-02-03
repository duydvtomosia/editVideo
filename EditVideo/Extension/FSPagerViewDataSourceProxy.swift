//
//  FSPagerViewDataSourceProxy.swift
//  EditVideo
//
//  Created by tomosia on 24/02/2023.
//

import FSPagerView
import RxCocoa
import RxSwift
import UIKit

extension FSPagerView: HasDataSource {
    public typealias DataSource = FSPagerViewDataSource
}

private let pagerViewDataSourceNotSet = PagerViewDataSourceNotSet()

private final class PagerViewDataSourceNotSet
    : NSObject, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        0
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        fatalError("DataSource not set")
    }
}

class RxPagerViewDataSourceProxy: DelegateProxy<FSPagerView, FSPagerViewDataSource>, DelegateProxyType {
    public private(set) weak var pagerView: FSPagerView?

    public init(pagerView: ParentObject) {
        self.pagerView = pagerView
        super.init(parentObject: pagerView, delegateProxy: RxPagerViewDataSourceProxy.self)
    }

    static func registerKnownImplementations() {
        register { RxPagerViewDataSourceProxy(pagerView: $0) }
    }

    private weak var _requiredMethodDataSource: FSPagerViewDataSource? = pagerViewDataSourceNotSet

    override func setForwardToDelegate(_ forwardDelegate: FSPagerViewDataSource?, retainDelegate: Bool) {
        _requiredMethodDataSource = forwardDelegate ?? pagerViewDataSourceNotSet
        super.setForwardToDelegate(forwardDelegate, retainDelegate: retainDelegate)
    }
}

extension RxPagerViewDataSourceProxy: FSPagerViewDataSource {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        (_requiredMethodDataSource ?? pagerViewDataSourceNotSet).numberOfItems(in: pagerView)
    }

    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        (_requiredMethodDataSource ?? pagerViewDataSourceNotSet).pagerView(pagerView, cellForItemAt: index)
    }
}
