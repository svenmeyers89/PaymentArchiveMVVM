//
//  SceneFactory.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 23.08.2025..
//

import SwiftUI

@MainActor
struct SceneFactory {
  private let paymentArchive: PaymentArchive
  
  init(paymentArchive: PaymentArchive) {
    self.paymentArchive = paymentArchive
  }
  
  func buildPaymentArchiveScene() -> PaymentArchiveView {
    let viewModel = PaymentArchiveViewModel(paymentArchive: paymentArchive)
    let paymentArchiveView = PaymentArchiveView(viewModel: viewModel)
    return paymentArchiveView
  }
  
  func buildEditAccountScene(useCase: EditAccountUseCase) -> EditAccountView {
    let viewModel = EditAccountViewModel(
      useCase: useCase,
      dataManager: paymentArchive
    )
    let editAccountView = EditAccountView(viewModel: viewModel)
    return editAccountView
  }
  
  func buildEditPaymentScene(useCase: EditPaymentUseCase) -> EditPaymentView {
    let viewModel = EditPaymentViewModel(
      useCase: useCase,
      currency: paymentArchive.currentState!.selectedAccount!.currency,
      categories: Payment.Category.allCases,
      dataManager: paymentArchive
    )
    let editPaymentView = EditPaymentView(viewModel: viewModel)
    return editPaymentView
  }
}
