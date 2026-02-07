//
//  PaymentArchiveStateWrapper.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.02.2026..
//

import Observation

@MainActor @Observable
final class PaymentArchiveStateWrapper {
  enum WrappedState {
    case missingInitialState
    case shouldOnboard
    case shouldLoadList(paymentGroups: [PaymentGroup], currency: Currency, selectedAccountId: String)
  }

  private(set) var state: WrappedState = .missingInitialState
  
  private let paymentArchive: PaymentArchive
  private let paymentGroupBuilder: PaymentArchiveGroupBuilder
  private let paymentArchiveCategorySelector: PaymentArchiveCategorySelector
  
  // non-isolation required for cancelation in deinit
  @ObservationIgnored
  private var task: Task<Void, Never>?
  
  init(
    paymentArchive: PaymentArchive,
    paymentGroupBuilder: PaymentArchiveGroupBuilder,
    paymentArchiveCategorySelector: PaymentArchiveCategorySelector
  ) {
    self.paymentArchive = paymentArchive
    self.paymentGroupBuilder = paymentGroupBuilder
    self.paymentArchiveCategorySelector = paymentArchiveCategorySelector
    
    task = Task { [weak self] in
      await self?.observe()
    }
  }
  
  deinit {
    task?.cancel()
  }

  private func observe() async {
    let combinedStream = combineLatest(
      paymentArchive.stateStream,
      paymentArchiveCategorySelector.selectionStream
    )
    
    do {
      for try await (state, selectedPaymentCategories) in combinedStream {
        await regenerateWrappedState(state, selectedPaymentCategories: selectedPaymentCategories)
      }
    } catch {
      fatalError("Combined stream should never fail!")
    }
  }

  private func regenerateWrappedState(
    _ state: PaymentArchive.State?,
    selectedPaymentCategories: Set<Payment.Category>
  ) async {
    guard let state else {
      self.state = .missingInitialState
      return
    }
    
    guard let selectedAccount = state.selectedAccount else {
      self.state = .shouldOnboard
      return
    }
    
    let allPayments: [Payment] = state.payments[selectedAccount.id] ?? []
    let selectedPaymentCategories = paymentArchiveCategorySelector.selectedPaymentCategories
    let filteredPayments: [Payment] = allPayments.filter { selectedPaymentCategories.contains($0.category) }
    let paymentGroups = await paymentGroupBuilder.groupPayments(using: filteredPayments, currency: selectedAccount.currency)
    
    self.state = .shouldLoadList(paymentGroups: paymentGroups, currency: selectedAccount.currency, selectedAccountId: selectedAccount.id)
  }
}

// --- move to other file!

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

func combineLatest<A: AsyncSequence, B: AsyncSequence>(
  _ a: A,
  _ b: B
) -> AsyncThrowingStream<(A.Element, B.Element), Error>
where
  A: Sendable,
  B: Sendable,
  A.Element: Sendable,
  B.Element: Sendable
// Starting with iOS 18, there's A.Failure which can be required to be Never
{
  AsyncThrowingStream { continuation in
    let state = AsyncSequenceCombineLatestState<A.Element, B.Element>()

    let t1 = Task {
      do {
        for try await value in a {
          if let pair = await state.updateElement1(value) {
            continuation.yield(pair)
          }
        }
      } catch {
        continuation.finish(throwing: error)
      }
    }

    let t2 = Task {
      do {
        for try await value in b {
          if let pair = await state.updateElement2(value) {
            continuation.yield(pair)
          }
        }
      } catch {
        continuation.finish(throwing: error)
      }
    }

    continuation.onTermination = { _ in
      t1.cancel()
      t2.cancel()
    }
  }
}
