//
//  PaymentArchiveCategorySelector.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.02.2026..
//

import Observation

@MainActor
final class PaymentArchiveCategorySelector {
  let allPaymentCategories: [Payment.Category]
  
  private(set) var selectedPaymentCategories: Set<Payment.Category> {
    didSet {
      continuation?.yield(selectedPaymentCategories)
    }
  }
  
  private var continuation: AsyncStream<Set<Payment.Category>>.Continuation?
  
  lazy var selectionStream: AsyncStream<Set<Payment.Category>> = {
    AsyncStream { continuation in
      self.continuation = continuation
      continuation.yield(selectedPaymentCategories)
    }
  }()
  
  init(
    allPaymentCategories: [Payment.Category],
    selectedPaymentCategories: Set<Payment.Category>
  ) {
    self.allPaymentCategories = allPaymentCategories
    self.selectedPaymentCategories = selectedPaymentCategories
  }
  
  func didConfirmSelection(paymentCategories: Set<Payment.Category>) {
    selectedPaymentCategories = paymentCategories
  }
}
