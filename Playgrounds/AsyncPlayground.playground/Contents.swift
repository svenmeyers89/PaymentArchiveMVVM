import Foundation
import PlaygroundSupport
import AsyncOperators

PlaygroundPage.current.needsIndefiniteExecution = true

@Observable class Person {
  var firstName: String = ""
}

func runObservationsTest() {
  let person = Person()
  
  person.firstName = "Perica"
  print("I can access person's first name directly: \(person.firstName)")

  // Create an async sequence to observe changes
  let observations = Observations<String, Never>.untilFinished {
    if person.firstName == "STOP" {
      return .finish
    }
    return .next(person.firstName)
  }

  Task {
    for await name in observations {
      print("Name updated: \(name)")
    }
    print("Observation ended.")
  }
  
  Task {
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    person.firstName = "John"
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    person.firstName = "Jane"
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    person.firstName = "STOP"
  }
}

// MARK: - CombineLatest

func makeStream(label: String, values: [Int], delayNanoseconds: UInt64) -> AsyncStream<Int> {
  AsyncStream { continuation in
    Task {
      for value in values {
        try? await Task.sleep(nanoseconds: delayNanoseconds)
        print("\(label) -> \(value)")
        continuation.yield(value)
      }
      continuation.finish()
    }
  }
}

func runCombineLatestTest() {
  let streamA = makeStream(label: "A", values: [1, 2, 3], delayNanoseconds: 250_000_000)
  let streamB = makeStream(label: "B", values: [10, 20], delayNanoseconds: 450_000_000)

  Task {
    do {
      for try await (a, b) in combineLatest(streamA, streamB) {
        print("combineLatest -> (\(a), \(b))")
      }
      print("combineLatest finished")
      PlaygroundPage.current.finishExecution()
    } catch {
      print("combineLatest error: \(error)")
      PlaygroundPage.current.finishExecution()
    }
  }
}

// MARK: - Composition

func runCompositionCombineLatestTest() {
  let streamA = makeStream(label: "A", values: [1, 2, 3, 4, 5, 6], delayNanoseconds: 250_000_000)
  let streamB = makeStream(label: "B", values: [10, 20, 30], delayNanoseconds: 450_000_000)
  let streamC = makeStream(label: "C", values: [100, 200, 300], delayNanoseconds: 600_000_000)
  
  Task {
    do {
      let compositionStream =
        combineLatest(
          streamA,
          combineLatest(
            streamB,
            streamC
          )
        )
        .map { (a, tupple) in (a, tupple.0, tupple.1) }
      
      for try await (a, b, c) in compositionStream {
        print("composition - combineLatest -> (\(a), \(b), \(c))")
      }
      
      print("composition - combineLatest finished")
      PlaygroundPage.current.finishExecution()
    } catch {
      print("composition - combineLatest error: \(error)")
      PlaygroundPage.current.finishExecution()
    }
  }
}

// MARK: - MainAsyncStream

actor CounterTracker {
  private let id: Int
  private let stream: AsyncStream<Int>

  init(id: Int, stream: AsyncStream<Int>) {
    self.id = id
    self.stream = stream
  }

  func track() async {
    for await count in stream {
      print("Tracker \(id) - did get \(count) from streamC")
    }
  }
}

func runMainSingleStreamTest() {
  Task { @MainActor in
    let stream = MainSingleAsyncStream<Int>(value: 0)
    
    let counter1 = CounterTracker(id: 1, stream: stream.stream)

    let t1 = Task {
      await counter1.track()
    }
    
    var t2: Task<Void, Never>? = nil
    
    for value in 1...6 {
      try? await Task.sleep(nanoseconds: 250_000_000)
      stream.value = value
      
      // Uncommenting the following code breaks the stream
//      if value == 3 {
//        t2 = Task {
//          let counter2 = CounterTracker(id: 2, stream: stream.stream)
//          await counter2.track()
//        }
//      }
    }
    
    t1.cancel()
    t2?.cancel()
    PlaygroundPage.current.finishExecution()
  }
}

// MARK: - Broadcaster

func runBroadcasterTest() {
  Task { @MainActor in
    let broadcaster = MainBroadcaster<Int>(value: 0)

    let counter1 = CounterTracker(id: 1, stream: broadcaster.makeStream())
    let counter2 = CounterTracker(id: 2, stream: broadcaster.makeStream())
    let counter3 = CounterTracker(id: 3, stream: broadcaster.makeStream())

    let t1 = Task {
      await counter1.track()
    }

    let t2 = Task {
      await counter2.track()
    }

    var t3: Task<Void, Never>? = nil
    var t4: Task<Void, Never>? = nil
    
    for value in 1...5 {
      try? await Task.sleep(nanoseconds: 250_000_000)
      broadcaster.value = value
      
      if value == 3 {
        t3 = Task {
          await counter3.track()
        }
        
        let counter4 = CounterTracker(id: 4, stream: broadcaster.makeStream())
        t4 = Task {
          await counter4.track()
        }
      }
    }

    t1.cancel()
    t2.cancel()
    t3?.cancel()
    t4?.cancel()
    PlaygroundPage.current.finishExecution()
  }
}

// MARK: - Testing

enum PlaygroundTest {
  case observations
  case combineLatest
  case composition
  case broadcaster
  case singleStream
}

let activeTest: PlaygroundTest = .observations

switch activeTest {
case .observations:
  runObservationsTest()
case .combineLatest:
  runCombineLatestTest()
case .composition:
  runCompositionCombineLatestTest()
case .broadcaster:
  runBroadcasterTest()
case .singleStream:
  runMainSingleStreamTest()
}
