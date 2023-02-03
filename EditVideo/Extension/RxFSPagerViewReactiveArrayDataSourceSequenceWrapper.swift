//
//  RxFSPagerViewReactiveArrayDataSourceSequenceWrapper.swift
//  EditVideo
//
//  Created by tomosia on 27/02/2023.
//

import FSPagerView
import RxCocoa
import RxSwift

class RxFSPagerViewReactiveArrayDataSourceSequenceWrapper<Sequence: Swift.Sequence>
    : RxFSPagerViewReactiveArrayDataSource<Sequence.Element>,
    RxFSPagerViewDataSourceType {
    func pagerView(_ pagerView: FSPagerView, observedEvent: RxSwift.Event<Sequence>) {
        Binder(self) { pagerViewDataSource, sectionModels in
            let sections = Array(sectionModels)
            pagerViewDataSource.pagerView(pagerView, observedElements: sections)
        }.on(observedEvent)
    }

    typealias Element = Sequence

    override init(cellFactory: @escaping CellFactory) {
        super.init(cellFactory: cellFactory)
    }
}

class RxFSPagerViewReactiveArrayDataSource<Element>
    : _RxFSPagerViewReactiveArrayDataSource,
    SectionedViewDataSourceType {
    typealias CellFactory = (FSPagerView, Int, Element) -> FSPagerViewCell

    var itemModels: [Element]?

    func modelAtIndex(_ index: Int) -> Element? {
        itemModels?[index]
    }

    func model(at indexPath: IndexPath) throws -> Any {
        precondition(indexPath.section == 0)
        guard let item = itemModels?[indexPath.item] else {
            throw RxCocoaError.itemsNotYetBound(object: self)
        }
        return item
    }

    let cellFactory: CellFactory

    init(cellFactory: @escaping CellFactory) {
        self.cellFactory = cellFactory
    }

    override func _numberOfItems(in pagerView: FSPagerView) -> Int {
        itemModels?.count ?? 0
    }

    override func _pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        cellFactory(pagerView, index, itemModels![index])
    }

    func pagerView(_ pagerView: FSPagerView, observedElements: [Element]) {
        itemModels = observedElements

        pagerView.reloadData()
    }
}

class _RxFSPagerViewReactiveArrayDataSource
    : NSObject, FSPagerViewDataSource {
    func _numberOfItems(in pagerView: FSPagerView) -> Int {
        0
    }

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        _numberOfItems(in: pagerView)
    }

    fileprivate func _pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        fatalError("Abstract method", file: #file, line: #line)
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        _pagerView(pagerView, cellForItemAt: index)
    }
}
