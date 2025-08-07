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

struct EditPaymentState: Sendable {
  let colors: EditPaymentView.Colors
  let edittedPayment: Payment?
  let selectedAccount: Account
  let categories: [Payment.Category]
}

@MainActor
enum EditPaymentSceneBuilder {
  static func build(
    initialState: EditPaymentState,
    dataManager: EditPaymentDataManager
  ) -> some View {
    let viewModel = EditPaymentViewModel(
      initialState: initialState,
      dataManager: dataManager
    )
    return EditPaymentView(viewModel: viewModel)
  }
}
