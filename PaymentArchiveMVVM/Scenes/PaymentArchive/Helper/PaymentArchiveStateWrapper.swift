//
//  PaymentArchiveStateWrapper.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.02.2026..
//

import AsyncOperators
import Observation

@MainActor @Observable
final class PaymentArchiveStateWrapper {
  enum WrappedState: Sendable, Equatable {
    case missingInitialState
    case shouldOnboard
    case shouldLoadList(paymentGroups: [PaymentGroup], currency: Currency, selectedAccountId: String)
  }

  private(set) var wrappedState: WrappedState = .missingInitialState
  
  private let paymentGroupBuilder: PaymentArchiveGroupBuilder
  
  /// deinit doesn't necessarily happen on Main thread...
  ///
  /// So either @ObservationIgnored or non-isolation attribute (for general use case) is required
  /// when cancelling in deinit
  @ObservationIgnored
  private var task: Task<Void, Never>?
  
  init(
    paymentArchiveStateStream: AsyncStream<PaymentArchive.State?>,
    selectedPaymentCategoriesStream: AsyncStream<Set<Payment.Category>>,
    paymentGroupBuilder: PaymentArchiveGroupBuilder
  ) {
    self.paymentGroupBuilder = paymentGroupBuilder
    
    task = Task { [weak self] in
      await self?
        .observe(
          paymentArchiveStateStream: paymentArchiveStateStream,
          selectedPaymentCategoriesStream: selectedPaymentCategoriesStream
        )
    }
  }
  
  deinit {
    task?.cancel()
  }

  private func observe(
    paymentArchiveStateStream: AsyncStream<PaymentArchive.State?>,
    selectedPaymentCategoriesStream: AsyncStream<Set<Payment.Category>>
  ) async {
    let combinedStream = combineLatest(
      paymentArchiveStateStream,
      selectedPaymentCategoriesStream
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
      self.wrappedState = .missingInitialState
      return
    }
    
    guard let selectedAccount = state.selectedAccount else {
      self.wrappedState = .shouldOnboard
      return
    }
    
    let allPayments: [Payment] = state.payments[selectedAccount.id] ?? []
    let filteredPayments: [Payment] = allPayments.filter { selectedPaymentCategories.contains($0.category) }
    let paymentGroups = await paymentGroupBuilder.groupPayments(using: filteredPayments, currency: selectedAccount.currency)
    
    self.wrappedState = .shouldLoadList(paymentGroups: paymentGroups, currency: selectedAccount.currency, selectedAccountId: selectedAccount.id)
  }
}
