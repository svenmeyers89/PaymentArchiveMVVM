// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

actor AsyncSequenceCombineLatestState<Element1, Element2> {
  var latest1: Element1?
  var latest2: Element2?

  func updateElement1(_ value: Element1) -> (Element1, Element2)? {
    latest1 = value
    guard let a = latest1, let b = latest2 else { return nil }
    return (a, b)
  }

  func updateElement2(_ value: Element2) -> (Element1, Element2)? {
    latest2 = value
    guard let a = latest1, let b = latest2 else { return nil }
    return (a, b)
  }
}

actor AsyncSequenceFinishOnce {
  private var finished: Bool = false
  private let finish: (Error?) -> Void

  init(finish: @escaping (Error?) -> Void) {
    self.finish = finish
  }

  func call(_ error: Error? = nil) {
    guard !finished else { return }
    finished = true
    finish(error)
  }
}

/// Note combineLatest doesn't return a shared/broadcast stream
/// For general use, call it separately for each subscriber
///
/// Starting with iOS 18, there's AsyncStream.Failure generic which can be set to be Never
/// That setup would enable AsyncSequence as returned type
///
/// Also, note that combineLatest completes at the moment when either A or B completes
public func combineLatest<A: AsyncSequence, B: AsyncSequence>(
  _ a: A,
  _ b: B
) -> AsyncThrowingStream<(A.Element, B.Element), Error>
where
  A: Sendable,
  B: Sendable,
  A.Element: Sendable,
  B.Element: Sendable
{
  AsyncThrowingStream { continuation in
    let state = AsyncSequenceCombineLatestState<A.Element, B.Element>()
    let finishOnce = AsyncSequenceFinishOnce { error in
      if let error {
        continuation.finish(throwing: error)
      } else {
        continuation.finish()
      }
    }

    let t1 = Task {
      do {
        for try await value in a {
          if let pair = await state.updateElement1(value) {
            continuation.yield(pair)
          }
        }
        await finishOnce.call()
      } catch {
        await finishOnce.call(error)
      }
    }

    let t2 = Task {
      do {
        for try await value in b {
          if let pair = await state.updateElement2(value) {
            continuation.yield(pair)
          }
        }
        await finishOnce.call()
      } catch {
        await finishOnce.call(error)
      }
    }

    continuation.onTermination = { _ in
      t1.cancel()
      t2.cancel()
    }
  }
}
