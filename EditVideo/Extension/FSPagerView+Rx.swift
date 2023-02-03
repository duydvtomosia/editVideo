//
//  FSPagerView+Rx.swift
//  EditVideo
//
//  Created by tomosia on 27/02/2023.
//

import FSPagerView
import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: FSPagerView {
    public func items<Sequence: Swift.Sequence, Source: ObservableType>
    (_ source: Source)
        -> (_ cellFactory: @escaping (FSPagerView, Int, Sequence.Element) -> FSPagerViewCell)
        -> Disposable
        where Source.Element == Sequence {
        return { cellFactory in
            let dataSource = RxFSPagerViewReactiveArrayDataSourceSequenceWrapper<Sequence>(cellFactory: cellFactory)
            return self.items(dataSource: dataSource)(source)
        }
    }

    public func items<
        DataSource: RxFSPagerViewDataSourceType & FSPagerViewDataSource,
        Source: ObservableType>
    (dataSource: DataSource)
        -> (_ source: Source) -> Disposable
        where DataSource.Element == Source.Element {
        return { source in
            _ = self.delegate
            return source.subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource as FSPagerViewDataSource, retainDataSource: true) { [weak pagerView = self.base] (_: RxPagerViewDataSourceProxy, event) in
                guard let pagerView = pagerView else { return }
                dataSource.pagerView(pagerView, observedEvent: event)
            }
        }
    }
}

extension ObservableType {
    func subscribeProxyDataSource<DelegateProxy: DelegateProxyType>(ofObject object: DelegateProxy.ParentObject, dataSource: DelegateProxy.Delegate, retainDataSource: Bool, binding: @escaping (DelegateProxy, Event<Element>) -> Void)
        -> Disposable
        where DelegateProxy.ParentObject: UIView
        , DelegateProxy.Delegate: AnyObject {
        let proxy = DelegateProxy.proxy(for: object)
        let unregisterDelegate = DelegateProxy.installForwardDelegate(dataSource, retainDelegate: retainDataSource, onProxyForObject: object)

        // Do not perform layoutIfNeeded if the object is still not in the view hierarchy
        if object.window != nil {
            // this is needed to flush any delayed old state (https://github.com/RxSwiftCommunity/RxDataSources/pull/75)
            object.layoutIfNeeded()
        }

        let subscription = asObservable()
            .observe(on: MainScheduler())
            .catch { error in
                bindingError(error)
                return Observable.empty()
            }
            // source can never end, otherwise it would release the subscriber, and deallocate the data source
            .concat(Observable.never())
            .take(until: object.rx.deallocated)
            .subscribe { [weak object] (event: Event<Element>) in

                if let object = object {
                    assert(proxy === DelegateProxy.currentDelegate(for: object), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(String(describing: DelegateProxy.currentDelegate(for: object)))")
                }

                binding(proxy, event)

                switch event {
                case let .error(error):
                    bindingError(error)
                    unregisterDelegate.dispose()
                case .completed:
                    unregisterDelegate.dispose()
                default:
                    break
                }
            }

        return Disposables.create { [weak object] in
            subscription.dispose()

            if object?.window != nil {
                object?.layoutIfNeeded()
            }

            unregisterDelegate.dispose()
        }
    }

    private func bindingError(_ error: Swift.Error) {
        let error = "Binding Error: \(error)"
        print(error)
    }
}
