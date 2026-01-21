//
//  PaymentArchiveViewModel.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.09.2025..
//

import Observation

@MainActor @Observable
final class PaymentArchiveViewModel {
  var contentType: PaymentArchiveView.ContentType {
    if let errorMessage {
      return .error(errorMessage)
    }
    guard let state = paymentArchive.state else {
      return .loading
    }
    if let selectedAccount = state.selectedAccount {
      let payments = state.payments[selectedAccount.id] ?? []
      return .listView(
        payments.filter { selectedPaymentCategories.contains($0.category) },
        currency: selectedAccount.currency,
        selectedAccountId: selectedAccount.id
      )
    } else {
      return .onboarding
    }
  }

  let allPaymentCategories: [Payment.Category] = Payment.Category.allCases
  private(set) var selectedPaymentCategories: Set<Payment.Category> = .init(Payment.Category.allCases)
  
  private var errorMessage: String?
  
  private let paymentArchive: PaymentArchive

  init(paymentArchive: PaymentArchive) {
    self.paymentArchive = paymentArchive
  }

  func loadContent() async {
    do {
      try await paymentArchive.loadInitialState()
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  func didConfirmSelection(paymentCategories: Set<Payment.Category>) {
    selectedPaymentCategories = paymentCategories
  }
}
