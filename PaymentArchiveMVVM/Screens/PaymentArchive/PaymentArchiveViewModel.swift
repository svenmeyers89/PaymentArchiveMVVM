//
//  PaymentArchiveViewModel.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.09.2025..
//

import Observation

@MainActor @Observable
final class PaymentArchiveCategorySelector2 {
  let allPaymentCategories: [Payment.Category]
  private(set) var selectedCategories: Set<Payment.Category>
  
  init(allPaymentCategories: [Payment.Category],
       selectedCategories: Set<Payment.Category>) {
    self.allPaymentCategories = allPaymentCategories
    self.selectedCategories = selectedCategories
  }
  
  func select(paymentCategories: Set<Payment.Category>) {
    selectedCategories = paymentCategories
  }
}

@MainActor @Observable
final class PaymentArchiveViewModel2 {
  private let paymentArchive: PaymentArchive
  private let paymentArchiveCategorySelector: PaymentArchiveCategorySelector2
  
  private let paymentGroupBuilder: PaymentArchiveGroupBuilder = .init()
  private let defaultPaymentCategorySelection: [Payment.Category] = Payment.Category.allCases
  
  private var errorMessage: String?
  
  private(set) var contentState: PaymentArchiveView.ContentType
  
  init(
    paymentArchive: PaymentArchive,
    selectedCategories: Set<Payment.Category>
  ) {
    self.paymentArchive = paymentArchive
    self.paymentArchiveCategorySelector = PaymentArchiveCategorySelector2(
      allPaymentCategories: defaultPaymentCategorySelection,
      selectedCategories: Set<Payment.Category>(defaultPaymentCategorySelection)
    )
    contentState = .loading
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
      }
    }
  }
  
  private func regenerateState(
    _ state: PaymentArchive.State?,
    selectedPaymentCategories: Set<Payment.Category>,
    errorMessage: String?
  ) async {
    guard let state else {
      self.contentState = .loading
      return
    }
    
    guard let selectedAccount = state.selectedAccount else {
      self.contentState = .onboarding
      return
    }
    
    let allPayments: [Payment] = state.payments[selectedAccount.id] ?? []
    let filteredPayments: [Payment] = allPayments.filter { selectedPaymentCategories.contains($0.category) }
    let paymentGroups = await paymentGroupBuilder.groupPayments(using: filteredPayments, currency: selectedAccount.currency)
    
    self.contentState = .listView(
      sections: paymentGroups,
      currency: selectedAccount.currency,
      selectedAccountId: selectedAccount.id,
      isDemoMode: state.isDemoMode
    )
  }
}

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
