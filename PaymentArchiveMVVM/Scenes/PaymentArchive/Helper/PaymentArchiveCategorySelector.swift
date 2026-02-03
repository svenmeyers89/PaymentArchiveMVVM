//
//  PaymentArchiveCategorySelector.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.02.2026..
//

import Observation

@MainActor @Observable
final class PaymentArchiveCategorySelector {
  let allPaymentCategories: [Payment.Category]
  private(set) var selectedPaymentCategories: Set<Payment.Category>
  
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
