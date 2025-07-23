//
//  EditPaymentSceneBuilder.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

protocol EditPaymentDataManager {
  func save(payment: Payment) async throws
}

@Observable @MainActor
final class EditPaymentState {
  var colors: EditPaymentView.Colors

  let edittedPayment: Payment?
  let currency: String
  let categories: [Payment.Category]
  
  init(
    colors: EditPaymentView.Colors,
    edittedPayment: Payment?,
    currency: String,
    categories: [Payment.Category]
  ) {
    self.colors = colors
    self.edittedPayment = edittedPayment
    self.currency = currency
    self.categories = categories
  }
}

@MainActor
enum EditPaymentSceneBuilder {
  static func build(
    state: EditPaymentState,
    dataManager: EditPaymentDataManager
  ) -> some View {
    let viewModel = EditPaymentViewModel(dataManager: dataManager)
    return EditPaymentView(
      state: state,
      viewModel: viewModel
    )
  }
}
