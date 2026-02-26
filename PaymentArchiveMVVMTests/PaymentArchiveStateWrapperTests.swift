//
//  PaymentArchiveStateWrapperTests.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 23.02.2026..
//

import Foundation
import Testing
@testable import PaymentArchiveMVVM

enum TestError: Error, Equatable {
  case boom
}

struct PaymentArchiveStateWrapperTests {
  @MainActor @Test
  func testStateWrapperUpdates() async throws {
    let (stateStream, stateContinuation) = AsyncStream<PaymentArchive.State?>.makeStream()
    let (selectorStream, selectorContinuation) = AsyncStream<Set<Payment.Category>>.makeStream()

    let wrapper = PaymentArchiveStateWrapper(
      paymentArchiveStateStream: stateStream,
      selectedPaymentCategoriesStream: selectorStream,
      paymentGroupBuilder: PaymentArchiveGroupBuilder()
    )
    
    // Testing initial state
    #expect(wrapper.wrappedState == .missingInitialState)
    
    await testTransitionToOnboardState(using: wrapper, stateContinuation: stateContinuation, selectorContinuation: selectorContinuation)
    
    await testTransitionToEmptyListState(using: wrapper, stateContinuation: stateContinuation, selectorContinuation: selectorContinuation)
  }
  
  @MainActor
  private func testTransitionToOnboardState(
    using wrapper: PaymentArchiveStateWrapper,
    stateContinuation: AsyncStream<PaymentArchive.State?>.Continuation,
    selectorContinuation: AsyncStream<Set<Payment.Category>>.Continuation
  ) async {
    let (changeTrackerStream, changeTrackerContinuation) = AsyncStream<Void>.makeStream()
    
    withObservationTracking {
      _ = wrapper.wrappedState
    } onChange: {
      changeTrackerContinuation.yield(())
    }
    
    // Load empty state
    stateContinuation.yield(PaymentArchive.State.empty)
    
    // Define init selection for wrapperState to combine it with PaymentArchive.State1
    selectorContinuation.yield([.groceries, .accommodation, .presents])
    
    await expectDidChange(in: changeTrackerStream)
    #expect(wrapper.wrappedState == .shouldOnboard)
  }
  
  @MainActor
  private func testTransitionToEmptyListState(
    using wrapper: PaymentArchiveStateWrapper,
    stateContinuation: AsyncStream<PaymentArchive.State?>.Continuation,
    selectorContinuation: AsyncStream<Set<Payment.Category>>.Continuation
  ) async {
    let (changeTrackerStream, changeTrackerContinuation) = AsyncStream<Void>.makeStream()
    
    withObservationTracking {
      _ = wrapper.wrappedState
    } onChange: {
      changeTrackerContinuation.yield(())
    }
    
    // Load empty list
    stateContinuation.yield(
      .init(
        selectedAccountId: "1",
        accounts: ["1": .init(
          id: "1",
          name: "Test Account",
          currency: Currency.eur,
          useBiometry: false
        )],
        payments: [:]
      ))
    
    await expectDidChange(in: changeTrackerStream)
    #expect(wrapper.wrappedState == .shouldLoadList(paymentGroups: [], currency: Currency.eur, selectedAccountId: "1"))
  }
  
  @MainActor
  private func expectDidChange(
    in stream: AsyncStream<Void>,
    timeout: Duration = .seconds(1)
  ) async {
    let didChange = await withTaskGroup(of: Bool.self) { group in
      group.addTask {
        var iterator = stream.makeAsyncIterator()
        return await iterator.next() != nil
      }
      group.addTask {
        try? await Task.sleep(for: timeout)
        return false
      }
      
      let result = await group.next() ?? false
      group.cancelAll()
      return result
    }
    
    #expect(didChange == true)
  }
}
