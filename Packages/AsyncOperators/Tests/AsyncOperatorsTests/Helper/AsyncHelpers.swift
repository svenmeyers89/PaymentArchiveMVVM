//
//  AsyncHelpers.swift
//  AsyncOperators
//
//  Created by Sven Majeric on 19.02.2026..
//

enum TestError: Error, Equatable {
  case boom
}

func delayedStream<T: Sendable>(
  _ values: [T],
  delayNanoseconds: UInt64
) -> AsyncStream<T> {
  AsyncStream { continuation in
    Task {
      for value in values {
        try? await Task.sleep(nanoseconds: delayNanoseconds)
        continuation.yield(value)
      }
      continuation.finish()
    }
  }
}

func delayedThrowingStream<T: Sendable>(
  values: [T],
  delayNanoseconds: UInt64,
  throwAfterValues: Bool = false
) -> AsyncThrowingStream<T, Error> {
  AsyncThrowingStream { continuation in
    Task {
      for value in values {
        try? await Task.sleep(nanoseconds: delayNanoseconds)
        continuation.yield(value)
      }
      if throwAfterValues {
        continuation.finish(throwing: TestError.boom)
      } else {
        continuation.finish()
      }
    }
  }
}

func collect<T: Sendable>(
  _ sequence: AsyncStream<T>,
  limit: Int
) async -> [T] {
  guard limit > 0 else {
    return []
  }

  var values: [T] = []

  for await value in sequence {
    values.append(value)
    if values.count == limit {
      break
    }
  }

  return values
}

func collectThrowing<T: Sendable>(
  _ sequence: AsyncThrowingStream<T, Error>,
  limit: Int
) async throws -> [T] {
  // This is essentially the same implementation as in collect(:limit:)
  // The only difference is sequence being AsyncThrowingStream so `try await` is required in while loop
  var iterator = sequence.makeAsyncIterator()
  var values: [T] = []

  while values.count < limit, let value = try await iterator.next() {
    values.append(value)
  }

  return values
}
