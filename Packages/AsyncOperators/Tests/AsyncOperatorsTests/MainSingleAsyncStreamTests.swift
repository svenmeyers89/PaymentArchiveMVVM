import Testing
@testable import AsyncOperators

@MainActor
@Test
func mainSingleAsyncStreamEmitsInitialAndUpdatedValues() async {
  let source = MainSingleAsyncStream(value: 5)
  let stream = source.stream

  let task = Task {
    await collect(stream, limit: 3)
  }

  await Task.yield()
  source.value = 6
  source.value = 7

  let values = await task.value
  #expect(values == [5, 6, 7])
}
