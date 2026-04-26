//
//  PaymentArchiveViewModel.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.09.2025..
//

import Observation

@MainActor @Observable
final class PaymentArchiveViewModel {
  private let paymentArchive: PaymentArchive
  private let paymentArchiveCategorySelector: PaymentArchiveCategorySelector
  
  private let paymentGroupBuilder: PaymentArchiveGroupBuilder = .init()
  private let defaultPaymentCategorySelection: [Payment.Category] = Payment.Category.allCases
  
  private var errorMessage: String?
  
  private(set) var contentType: PaymentArchiveView.ContentType
  
  var allPaymentCategories: [Payment.Category] {
    paymentArchiveCategorySelector.allPaymentCategories
  }
  
  var selectedPaymentCategories: Set<Payment.Category> {
    paymentArchiveCategorySelector.selectedCategories
  }
  
  init(paymentArchive: PaymentArchive) {
    self.paymentArchive = paymentArchive
    self.paymentArchiveCategorySelector = PaymentArchiveCategorySelector(
      allPaymentCategories: defaultPaymentCategorySelection,
      selectedCategories: Set<Payment.Category>(defaultPaymentCategorySelection)
    )
    contentType = .loading
    
    observe()
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
    paymentArchiveCategorySelector
      .select(
        paymentCategories: paymentCategories
      )
  }

  func enterDemoMode() async {
    do {
      try await paymentArchive.enterDemoMode()
      paymentArchiveCategorySelector
        .select(
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
      paymentArchiveCategorySelector
        .select(
          paymentCategories: Set<Payment.Category>(defaultPaymentCategorySelection)
        )
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  private func observe() {
    withObservationTracking {
      _ = paymentArchive.observableState
      _ = paymentArchiveCategorySelector.selectedCategories
      _ = errorMessage
    } onChange: {
      Task {
        await self.regenerateState(
          self.paymentArchive.observableState,
          selectedPaymentCategories: self.paymentArchiveCategorySelector.selectedCategories,
          errorMessage: self.errorMessage
        )
        
        await self.observe()
      }
    }
  }
  
  private func regenerateState(
    _ state: PaymentArchive.State?,
    selectedPaymentCategories: Set<Payment.Category>,
    errorMessage: String?
  ) async {
    guard let state else {
      self.contentType = .loading
      return
    }
    
    guard let selectedAccount = state.selectedAccount else {
      self.contentType = .onboarding
      return
    }
    
    let allPayments: [Payment] = state.payments[selectedAccount.id] ?? []
    let filteredPayments: [Payment] = allPayments.filter { selectedPaymentCategories.contains($0.category) }
    let paymentGroups = await paymentGroupBuilder.groupPayments(using: filteredPayments, currency: selectedAccount.currency)
    
    self.contentType = .listView(
      sections: paymentGroups,
      currency: selectedAccount.currency,
      selectedAccountId: selectedAccount.id,
      isDemoMode: state.isDemoMode
    )
  }
}
