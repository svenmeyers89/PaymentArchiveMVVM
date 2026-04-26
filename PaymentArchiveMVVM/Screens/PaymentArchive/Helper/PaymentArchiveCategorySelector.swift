//
//  PaymentArchiveCategorySelector.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.02.2026..
//

import AsyncOperators
import Observation

@MainActor @Observable
final class PaymentArchiveCategorySelector {
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
