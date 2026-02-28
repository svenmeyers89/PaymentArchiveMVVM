//
//  MainBroadcasterTests.swift
//  AsyncOperators
//
//  Created by Sven Majeric on 19.02.2026..
//

import Testing
@testable import AsyncOperators

@MainActor
@Test
func mainBroadcasterSharesInitialAndUpdatedValuesAcrossSubscribers() async {
  let broadcaster = MainBroadcaster(value: 0)
  let stream1 = broadcaster.makeStream()
  let stream2 = broadcaster.makeStream()

  let task1 = Task {
    await collect(stream1, limit: 3)
  }
  let task2 = Task {
    await collect(stream2, limit: 3)
  }

  // Give the two collector tasks a chance to start before mutating broadcaster.value
  await Task.yield()

  broadcaster.value = 1
  broadcaster.value = 2
  
  let stream3 = broadcaster.makeStream()
  let task3 = Task {
    await collect(stream3, limit: 2)
  }

  let values1 = await task1.value
  let values2 = await task2.value
  
  broadcaster.value = 3
  
  let values3 = await task3.value

  #expect(values1 == [0, 1, 2])
  #expect(values2 == [0, 1, 2])
  #expect(values3 == [2, 3])
}
