//
//  FSPagerView+Rx.swift
//  EditVideo
//
//  Created by tomosia on 24/02/2023.
//

import FSPagerView
import RxCocoa
import RxSwift

extension FSPagerView: HasDelegate {
    public typealias Delegate = FSPagerViewDelegate
}

class RxFSPagerViewDelegateProxy: DelegateProxy<FSPagerView, FSPagerViewDelegate>, DelegateProxyType, FSPagerViewDelegate {
    public private(set) weak var fsPagerView: FSPagerView?

    public init(fsPagerView: ParentObject) {
        self.fsPagerView = fsPagerView
        super.init(parentObject: fsPagerView, delegateProxy: RxFSPagerViewDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        register(make: { RxFSPagerViewDelegateProxy(fsPagerView: $0) })
    }
}

extension Reactive where Base: FSPagerView {
    var delegate: DelegateProxy<FSPagerView, FSPagerViewDelegate> {
        return RxFSPagerViewDelegateProxy.proxy(for: base)
    }

    var didSelectItem: Observable<Int> {
        return delegate
            .methodInvoked(#selector(FSPagerViewDelegate.pagerView(_:didSelectItemAt:)))
            .map { $0[1] as! Int }
    }

    var willEndDragging: Observable<Int> {
        return delegate
            .methodInvoked(#selector(FSPagerViewDelegate.pagerViewWillEndDragging(_:targetIndex:)))
            .map { $0[1] as! Int }
    }

    
}
