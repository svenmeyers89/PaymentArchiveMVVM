//
//  PaymentArchiveCategorySelectorTests.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 21.02.2026..
//

import Testing
@testable import PaymentArchiveMVVM

struct PaymentArchiveCategorySelectorTests {
  @Test @MainActor
  func testPaymentArchiveCategorySelection() async throws {
    let categorySelector = PaymentArchiveCategorySelector(
      allPaymentCategories: [.groceries, .accommodation, .shopping, .transport],
      selectedPaymentCategories: .init()
    )
    
    #expect(categorySelector.currentlySelectedPaymentCategories.isEmpty)
    
    let categorySelectionIterations: [Set<Payment.Category>] = [
      .init([.groceries]),
      .init([.groceries, .shopping]),
      .init([.accommodation])
    ]

    let expectedOrder = [Set<Payment.Category>()] + categorySelectionIterations
    let collectTask = Task {
      var received: [Set<Payment.Category>] = []
      for await selectedCategories in categorySelector.selectionStream {
        received.append(selectedCategories)
        if received.count == expectedOrder.count {
          break
        }
      }
      return received
    }

    await Task.yield() // Ensure the stream consumer is attached first.

    for categories in categorySelectionIterations {
      try await select(categories: categories, categorySelector: categorySelector)
    }

    let received = await collectTask.value

    #expect(received == expectedOrder)
    #expect(categorySelector.currentlySelectedPaymentCategories == categorySelectionIterations[2])
  }
  
  private func select(
    categories: Set<Payment.Category>,
    categorySelector: PaymentArchiveCategorySelector
  ) async throws {
    try await Task.sleep(nanoseconds: 50_000_000)
    await categorySelector.didConfirmSelection(paymentCategories: categories)
  }
}
