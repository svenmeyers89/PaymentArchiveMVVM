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
  
  func buildEditAccountScene(account: Account?) -> EditAccountView {
    let viewModel = EditAccountViewModel(
      edittedAccount: account,
      dataManager: paymentArchive
    )
    let editAccountView = EditAccountView(viewModel: viewModel)
    return editAccountView
  }
  
  func buildEditPaymentScene(payment: Payment?) -> EditPaymentView {
    let viewModel = EditPaymentViewModel(
      edittedPayment: payment,
      selectedAccount: paymentArchive.state!.selectedAccount!,
      categories: Payment.Category.allCases,
      dataManager: paymentArchive
    )
    let editPaymentView = EditPaymentView(viewModel: viewModel)
    return editPaymentView
  }
}
