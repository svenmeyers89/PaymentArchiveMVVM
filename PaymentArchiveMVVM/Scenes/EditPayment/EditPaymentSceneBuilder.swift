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

@MainActor
enum EditPaymentSceneBuilder {
  static func build(dataManager: EditPaymentDataManager) -> some View {
    let viewModel = EditPaymentViewModel(dataManager: dataManager)
    return EditPaymentView(viewModel: viewModel)
  }
}
