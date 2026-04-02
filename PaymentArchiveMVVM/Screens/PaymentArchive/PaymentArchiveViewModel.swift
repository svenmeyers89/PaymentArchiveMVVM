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
    
    let state = stateWrapper.wrappedState
    
    switch state {
    case .missingInitialState:
      return .loading
    case .shouldOnboard:
      return .onboarding
    case let .shouldLoadList(paymentGroups, currency, selectedAccountId, isDemoMode):
      return .listView(sections: paymentGroups, currency: currency, selectedAccountId: selectedAccountId, isDemoMode: isDemoMode)
    }
  }
  
  var allPaymentCategories: [Payment.Category] {
    paymentArchiveCategorySelector.allPaymentCategories
  }
  
  var selectedPaymentCategories: Set<Payment.Category> {
    paymentArchiveCategorySelector.currentlySelectedPaymentCategories
  }
  
  private var errorMessage: String?

  private let stateWrapper: PaymentArchiveStateWrapper
  private let paymentArchive: PaymentArchive
  private let paymentArchiveCategorySelector: PaymentArchiveCategorySelector
  
  private let defaultPaymentCategorySelection: [Payment.Category] = Payment.Category.allCases

  init(paymentArchive: PaymentArchive) {
    self.paymentArchive = paymentArchive
    self.paymentArchiveCategorySelector = .init(
      allPaymentCategories: defaultPaymentCategorySelection,
      selectedPaymentCategories: Set<Payment.Category>(defaultPaymentCategorySelection)
    )
    self.stateWrapper = .init(
      paymentArchiveStateStream: paymentArchive.makeStateStream(),
      selectedPaymentCategoriesStream: paymentArchiveCategorySelector.selectionStream,
      paymentGroupBuilder: PaymentArchiveGroupBuilder()
    )
  }

  func loadContent() async {
    do {
      try await paymentArchive.loadData()
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  func didConfirmSelection(paymentCategories: Set<Payment.Category>) {
    paymentArchiveCategorySelector.select(paymentCategories: paymentCategories)
  }

  func enterDemoMode() async {
    do {
      try await paymentArchive.enterDemoMode()
      paymentArchiveCategorySelector.select(
        paymentCategories: Set<Payment.Category>(defaultPaymentCategorySelection)
      )
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  func exitDemoMode() async {
    do {
      try await paymentArchive.exitDemoMode()
      paymentArchiveCategorySelector.select(
        paymentCategories: Set<Payment.Category>(defaultPaymentCategorySelection)
      )
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
