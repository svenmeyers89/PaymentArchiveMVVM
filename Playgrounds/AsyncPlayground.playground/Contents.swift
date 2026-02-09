import Foundation
import PlaygroundSupport
import AsyncOperators

PlaygroundPage.current.needsIndefiniteExecution = true

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

// MARK: - Broadcaster

@MainActor
final class BroadcastIntStream {
  private var continuations: [UUID: AsyncStream<Int>.Continuation] = [:]
  private var counter: Int = 0

  func makeStream() -> AsyncStream<Int> {
    AsyncStream { continuation in
      let id = UUID()
      continuations[id] = continuation
      print("## Added a new continuation with id: \(id)")
      continuation.yield(counter)
      continuation.onTermination = { [weak self] _ in
        Task { @MainActor in
          self?.continuations.removeValue(forKey: id)
        }
      }
    }
  }

  func set(_ value: Int) {
    counter = value
    for continuation in continuations.values {
      continuation.yield(value)
    }
  }
}

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

func runBroadcasterTest() {
  Task {
    let broadcaster = await BroadcastIntStream()

    let counter1 = CounterTracker(id: 1, stream: await broadcaster.makeStream())
    let counter2 = CounterTracker(id: 2, stream: await broadcaster.makeStream())
    let counter3 = CounterTracker(id: 3, stream: await broadcaster.makeStream())

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
      await broadcaster.set(value)
      
      if value == 3 {
        t3 = Task {
          await counter3.track()
        }
        
        let counter4 = CounterTracker(id: 4, stream: await broadcaster.makeStream())
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
  case combineLatest
  case broadcaster
}

let activeTest: PlaygroundTest = .combineLatest

switch activeTest {
case .combineLatest:
  runCombineLatestTest()
case .broadcaster:
  runBroadcasterTest()
}
