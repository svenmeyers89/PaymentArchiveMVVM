//
//  EditPaymentSceneBuilder.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

protocol EditPaymentDataManager: Sendable {
  func save(payment: Payment) async throws
}

@Observable @MainActor
final class EditPaymentState {
  var colors: EditPaymentView.Colors

  let edittedPayment: Payment?
  let selectedAccount: Account
  let categories: [Payment.Category]
  
  init(
    colors: EditPaymentView.Colors,
    edittedPayment: Payment?,
    selectedAccount: Account,
    categories: [Payment.Category]
  ) {
    self.colors = colors
    self.edittedPayment = edittedPayment
    self.selectedAccount = selectedAccount
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
