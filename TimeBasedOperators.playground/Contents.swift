//import RxSwift
//import UIKit
//
//func observableWithTimer() {
//    let bag = DisposeBag()
//    let elementsPerSecond = 1
//    let maxElements = 5
//    let replayedElements = 1
//    let replayedRelay: TimeInterval = 3
//
//    let observable = Observable<Int>.create { observer -> Disposable in
//        var value = 1
//        let source = DispatchSource.makeTimerSource(queue: .main)
//        source.setEventHandler {
//            if value <= maxElements {
//                observer.onNext(value)
//                value += 1
//            }
//
//            source.schedule(deadline: .now(),
//                            repeating: 1.0 / Double(elementsPerSecond),
//                            leeway: .nanoseconds(0))
//            source.resume()
//
//            return Disposables.create {
//                source.suspend()
//            }
//        }
//    }
//
//    DispatchQueue.main.async {
//        observable
//            .subscribe(onNext: { value in
//                print("🔵 : ", value)
//            }, onCompleted: {
//                print("🔵 Completed")
//            }, onDisposed: {
//                print("🔵 Disposed")
//            })
//            .disposed(by: bag)
//    }
//}


let string = "8558440114"
print("\(Int64(string))")
