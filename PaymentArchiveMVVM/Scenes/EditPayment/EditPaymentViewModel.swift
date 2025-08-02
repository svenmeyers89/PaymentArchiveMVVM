//
//  EditPaymentViewModel.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

enum EditPaymentError: Error {
  case invalidMoneyAmountFormat
  case categoryEmpty
  case savePaymentFailed(Error)
  
  var toastBarMessage: ToastBar.Message {
    switch self {
    case .invalidMoneyAmountFormat:
      return .init(
        text: "Something went wrong",
        type: .error
      )
    case .categoryEmpty:
      return .init(
        text: "Please select category",
        type: .error
      )
    case .savePaymentFailed(let underlyingError):
      return .init(
        text: "Saving payment failed: \(underlyingError.localizedDescription)",
        type: .error
      )
    }
  }
}

@MainActor
final class EditPaymentViewModel {
  nonisolated private let dataManager: EditPaymentDataManager
  
  init(dataManager: EditPaymentDataManager) {
    self.dataManager = dataManager
  }
  
  func savePayment(
    amountString: String,
    category: Payment.Category?,
    note: String?,
    selectedAccount: Account,
    edittedPayment: Payment?
  ) async -> Result<Void, EditPaymentError> {
    guard let amount = NumberFormatter().number(from: amountString)?.floatValue else {
      return .failure(.invalidMoneyAmountFormat)
    }
    guard let category else {
      return .failure(.categoryEmpty)
    }
    let updatedPayment: Payment = {
      if let edittedPayment {
        let updatedPayment = edittedPayment
          .updated(amount: amount, category: category, note: note)
        return updatedPayment
      } else {
        return .init(
          accountId: selectedAccount.id,
          amount: amount,
          category: category,
          note: note
        )
      }
    }()
    do {
      try await dataManager.save(payment: updatedPayment)
      return .success(())
    } catch {
      return .failure(.savePaymentFailed(error))
    }
  }
}

extension Payment {
  func updated(amount: Float, category: Payment.Category, note: String?) -> Payment {
    var updatedPayment = self
    updatedPayment.amount = amount
    updatedPayment.category = category
    updatedPayment.note = note
    return updatedPayment
  }
}
