//
//  CombineLatestTests.swift
//  AsyncOperators
//
//  Created by Sven Majeric on 19.02.2026..
//

import Testing
@testable import AsyncOperators

private struct TestTuple: Sendable, Equatable {
  let a: Int
  let b: String
}

@Test
func combineLatestEmitsLatestPairsAfterBothHaveValues() async throws {
  let a = delayedStream([1, 2, 3], delayNanoseconds: 30_000_000)
  let b = delayedStream(["a", "b"], delayNanoseconds: 40_000_000)

  let combined = combineLatest(a, b)
  let values = try await collectThrowing(combined, limit: 10)
  let mappedValues = values.map { TestTuple(a: $0.0, b: $0.1) }

  #expect(mappedValues == [
    TestTuple(a: 1, b: "a"),
    TestTuple(a: 2, b: "a"),
    TestTuple(a: 2, b: "b")
  ])
}

@Test
func combineLatestFinishesWhenOneSequenceCompletes() async throws {
  let a = delayedStream([1], delayNanoseconds: 10_000_000)
  let b = delayedStream([10, 20, 30], delayNanoseconds: 100_000_000)

  let combined = combineLatest(a, b)
  let values = try await collectThrowing(combined, limit: 10)

  #expect(values.isEmpty)
}

@Test
func combineLatestPropagatesUpstreamError() async {
  let a = delayedStream([1, 2, 3], delayNanoseconds: 20_000_000)
  let b = delayedThrowingStream(
    values: [10],
    delayNanoseconds: 25_000_000,
    throwAfterValues: true
  )

  let combined = combineLatest(a, b)

  await #expect(throws: TestError.boom) {
    _ = try await collectThrowing(combined, limit: 10)
  }
}
