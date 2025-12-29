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
    if let selectedAccountId = state.selectedAccountId {
      let payments = state.payments[selectedAccountId] ?? []
      return .listView(payments, selectedAccountId: selectedAccountId)
    } else {
      return .onboarding
    }
  }

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
}
