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
    
    let (wrappedStateStream, wrappedStateContinuation) = AsyncStream<PaymentArchiveStateWrapper.WrappedState>.makeStream()
    
    let wrapper = PaymentArchiveStateWrapper(
      paymentArchiveStateStream: stateStream,
      selectedPaymentCategoriesStream: selectorStream,
      paymentGroupBuilder: PaymentArchiveGroupBuilder()
    )
    
    #expect(wrapper.wrappedState == .missingInitialState)
    
    var iterator = wrappedStateStream.makeAsyncIterator()

    selectorContinuation.yield(.init([.groceries, .accommodation, .presents]))
    
    // selecting categories takes no effect at this stage
    //await awaitWrappedState(.missingInitialState, in: wrapper)
   // #expect(wrappedState == .missingInitialState)
    
    emitNextWrapperState(from: wrapper, on: wrappedStateContinuation)
    stateContinuation.yield(
      .init(
        selectedAccountId: nil,
        accounts: [:],
        payments: [:]
      )
    )
    
    //await awaitWrappedState(.shouldOnboard, in: wrapper)
    var wrappedState = await iterator.next()
    #expect(wrappedState == .shouldOnboard)
    
    selectorContinuation.yield(.init([.groceries, .accommodation, .presents, .healthcare]))
    
    // selecting categories takes no effect at this stage
    //await awaitWrappedState(.shouldOnboard, in: wrapper)
    //#expect(wrappedState == .shouldOnboard)
    
    emitNextWrapperState(from: wrapper, on: wrappedStateContinuation)
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
    
//    await awaitWrappedState(
//      .shouldLoadList(paymentGroups: [], currency: Currency.eur, selectedAccountId: "1"),
//      in: wrapper
//    )
    wrappedState = await iterator.next()
    #expect(wrappedState == .shouldLoadList(paymentGroups: [], currency: Currency.eur, selectedAccountId: "1"))
  }
  
  @MainActor
  private func emitNextWrapperState(
    from wrapper: PaymentArchiveStateWrapper,
    on continuation: AsyncStream<PaymentArchiveStateWrapper.WrappedState>.Continuation
  ) {
    withObservationTracking {
      _ = wrapper.wrappedState
    } onChange: {
      Task { @MainActor in
        continuation.yield(wrapper.wrappedState)
      }
    }
  }
  
  
  @MainActor
  private func awaitWrappedState(
    _ expected: PaymentArchiveStateWrapper.WrappedState,
    in wrapper: PaymentArchiveStateWrapper,
    timeout: Duration = .seconds(1),
    pollIntervalNanoseconds: UInt64 = 10_000_000
  ) async {
    let deadline = ContinuousClock.now + timeout
    while ContinuousClock.now < deadline {
      if wrapper.wrappedState == expected {
        return
      }
      try? await Task.sleep(nanoseconds: pollIntervalNanoseconds)
    }
    #expect(wrapper.wrappedState == expected)
  }
}
