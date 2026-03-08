//
//  PaymentArchiveCategorySelector.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.02.2026..
//

import AsyncOperators
import Observation

@MainActor
final class PaymentArchiveCategorySelector {
  let allPaymentCategories: [Payment.Category]
  
  private let stream: MainSingleAsyncStream<Set<Payment.Category>>
  
  var currentlySelectedPaymentCategories: Set<Payment.Category> {
    stream.value
  }

  lazy var selectionStream: AsyncStream<Set<Payment.Category>> = {
    stream.stream
  }()
  
  init(
    allPaymentCategories: [Payment.Category],
    selectedPaymentCategories: Set<Payment.Category>
  ) {
    self.allPaymentCategories = allPaymentCategories
    self.stream = .init(value: selectedPaymentCategories)
  }
  
  func didConfirmSelection(paymentCategories: Set<Payment.Category>) {
    stream.value = paymentCategories
  }
}
