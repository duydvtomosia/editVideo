import RxCocoa
import RxSwift
import UIKit

// let subject = PublishSubject<String>()
//
// subject.onNext("1")
//
// let subscription1 = subject.subscribe { value in
//    print("sub 1: \(value)")
// }
//
// subject.onNext("2")
//
// let subscription2 = subject.subscribe { value in
//    print("sub 2: \(value)")
// }
//
// subject.onNext("3")
// subject.onNext("4")
//
// let disposeBag = DisposeBag()
//
// subscription2.dispose()
//
// subject.onNext("5")
// subject.on(.completed)
// subject.onNext("6")
//
// subject.subscribe {
//    print("sub 3: ", $0.element ?? $0)
// }.disposed(by: disposeBag)

let disposeBag = DisposeBag()

let hello = Observable.from(["1", "2", "3", "4", "5", "6", "7", "8"])

// MARK: - filter operator

// hello
//    .map { string -> Int in
//        Int(string) ?? 0
//    }
//    .filter { $0 % 2 == 0 }
//    .subscribe(onNext: { value in
//        print(value)
//    }, onError: { error in
//        print(error)
//    }, onCompleted: {
//        print("Completed")
//    }) {
//        print("Dispose")
//    }
//    .disposed(by: disposeBag)

// MARK: - Skip

// hello
//    .skip(3)
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)

// MARK: - skip while

// hello
//    .map { string -> Int in
//        Int(string) ?? 0
//    }
//    .skip(while: { $0 % 2 == 0 })
//    .subscribe(onNext: { print($0) })
//    .disposed(by: disposeBag)

// MARK: - Relay Subject

// let bag = DisposeBag()
// let replaySubject = ReplaySubject<String>.create(bufferSize: 2) // khởi tạo một ReplaySubject kiểu String với size của buffer là 2
//
// replaySubject.onNext("Emit 1") // Phát ra một emit với String "Emit 1"
// replaySubject.onNext("Emit 2") // Phát ra một emit với String "Emit 2"
// replaySubject.onNext("Emit 3") // Phát ra một emit với String "Emit 3"
// replaySubject.onNext("Emit 10") // Phát ra một emit với String "Emit 1"
//
// print("- Before subscribe -")
// let subscriber = replaySubject.subscribe { element in // tạo ra một Subscriber để lắng nghe sự kiện từ replaySubject
//    print("Subscriber: \(element)")
// }
//
// subscriber.disposed(by: bag)
// print("- After subscribe -")
//
// replaySubject.onNext("Emit 4")
// replaySubject.onNext("Emit 5")
// replaySubject.onNext("Emit 6")
// replaySubject.onNext("Emit 7")

// MARK: - Map

// Observable<Int>.of(1, 2, 3, 4, 5, 6, 7)
//    .map { element in
//        element * 10
//    }
//    .subscribe(onNext: { print($0) })
//    .disposed(by: disposeBag)
//

// MARK: - flat map


// struct Student {
//    var name: String
//    var score: BehaviorRelay<Int>
// }
//
// let studentA = Student(name: "Mr.A", score: BehaviorRelay(value: 5))
// let studentB = Student(name: "Mr.B", score: BehaviorRelay(value: 10))
// let studentC = Student(name: "Mr.C", score: BehaviorRelay(value: 15))
//
// let sourceObservable = Observable.of(studentA, studentB, studentC)

// sourceObservable
//    .flatMap { element in
//        element.score.asObservable()
//    }
//    .subscribe(onNext: { print("flatMap: Student's score: \($0)") })
//    .disposed(by: disposeBag)

// sourceObservable
//    .map { $0.score.asObservable() }
//    .subscribe(onNext: { print("Score: \($0)") })
//    .disposed(by: disposeBag)
// studentA.score.accept(25)
// studentB.score.accept(30)
// studentC.score.accept(35)

// MARK: - flatMapLatest

// sourceObservable
//    .flatMapLatest { $0.score.asObservable() }
//    .subscribe(onNext: { print("flatMapLatest: Student score ", $0) })
//    .disposed(by: disposeBag)
//
// studentA.score.accept(25)
// studentB.score.accept(30)
// studentC.score.accept(35)

// MARK: - merge
//
//struct ObservableError: Error {
//    var description: String
//}
//
//let firstObservable = PublishSubject<String>()
//let secondObservable = PublishSubject<String>()
//
//Observable.merge(firstObservable, secondObservable)
//    .subscribe { element in
//        print(element)
//    }
//    .disposed(by: disposeBag)
//
//firstObservable.onNext("firstObservable 1")
//secondObservable.onNext("secondObservable 1")
//secondObservable.onNext("secondObservable 2")
//secondObservable.onNext("secondObservable 3")
//firstObservable.on(.error(ObservableError(description: "")))
//firstObservable.onNext("firstObservable 2")
//secondObservable.onNext("secondObservable 4")
//

// MARK: - Single

//func divideNumber(_ a: Int, _ b: Int) -> Single<Int> {
//    return Single.create { single in
//        if b == 0 {
//            single(.failure(NSError()))
//        } else {
//            single(.success(a / b))
//        }
//        return Disposables.create()
//    }
//}
//
//divideNumber(10, 2)
//    .subscribe { element in
//        switch element {
//        case .success(let result):
//            print("result: \(result)")
//        case .failure(let error):
//            print(error.localizedDescription)
//        }
//    }
//    .disposed(by: disposeBag)
