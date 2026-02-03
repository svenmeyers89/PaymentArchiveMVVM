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
    
    let state = stateWrapper.state
    
    switch state {
    case .missingInitialState:
      return .loading
    case .shouldOnboard:
      return .onboarding
    case let .shouldLoadList(paymentGroups, currency, selectedAccountId):
      return .listView(sections: paymentGroups, currency: currency, selectedAccountId: selectedAccountId)
    }
  }
  
  var allPaymentCategories: [Payment.Category] {
    paymentArchiveCategorySelector.allPaymentCategories
  }
  
  var selectedPaymentCategories: Set<Payment.Category> {
    paymentArchiveCategorySelector.selectedPaymentCategories
  }
  
  private var errorMessage: String?

  private let stateWrapper: PaymentArchiveStateWrapper
  private let paymentArchive: PaymentArchive
  private let paymentArchiveCategorySelector: PaymentArchiveCategorySelector

  init(paymentArchive: PaymentArchive) {
    self.paymentArchive = paymentArchive
    self.paymentArchiveCategorySelector = .init(
      allPaymentCategories: Payment.Category.allCases,
      selectedPaymentCategories: Set<Payment.Category>(Payment.Category.allCases)
    )
    self.stateWrapper = .init(
      paymentArchive: paymentArchive,
      paymentGroupBuilder: PaymentArchiveGroupBuilder(),
      paymentArchiveCategorySelector: paymentArchiveCategorySelector
    )
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
    paymentArchiveCategorySelector.didConfirmSelection(paymentCategories: paymentCategories)
  }
}
