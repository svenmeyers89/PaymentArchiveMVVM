//
//  EditPaymentViewModel.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

@MainActor
final class EditPaymentViewModel {
  private let dataManager: EditPaymentDataManager
  
  init(dataManager: EditPaymentDataManager) {
    self.dataManager = dataManager
  }
}
