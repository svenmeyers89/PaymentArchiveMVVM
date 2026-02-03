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
  
  init(
    paymentArchive: PaymentArchive,
    paymentGroupBuilder: PaymentArchiveGroupBuilder,
    paymentArchiveCategorySelector: PaymentArchiveCategorySelector
  ) {
    self.paymentArchive = paymentArchive
    self.paymentGroupBuilder = paymentGroupBuilder
    self.paymentArchiveCategorySelector = paymentArchiveCategorySelector
    
    observeState()
  }

  private func observeState() {
    withObservationTracking {
      _ = paymentArchive.state
      _ = paymentArchiveCategorySelector.selectedPaymentCategories
    } onChange: { [weak self] in
      Task {
        await self?.regenerateState()
        await self?.observeState()
      }
    }
  }

  private func regenerateState() async {
    guard let state = paymentArchive.state else {
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
