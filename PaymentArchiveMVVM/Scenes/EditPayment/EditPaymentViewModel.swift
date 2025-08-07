//
//  EditPaymentViewModel.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

enum EditPaymentError: Error {
  case moneyAmountCannotBeEmptyOrZero
  case categoryEmpty
  case savePaymentFailed(Error)
  
  var toastBarMessage: ToastBar.Message {
    switch self {
    case .moneyAmountCannotBeEmptyOrZero:
      return .init(
        text: "Please enter non-trivial money amount",
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

@MainActor @Observable
final class EditPaymentViewModel {
  private(set) var state: EditPaymentState

  nonisolated private let dataManager: EditPaymentDataManager

  init(
    initialState: EditPaymentState,
    dataManager: EditPaymentDataManager
  ) {
    self.state = initialState
    self.dataManager = dataManager
  }
  
  func savePayment(
    amount: Float?,
    category: Payment.Category?,
    note: String?
  ) async -> Result<Void, EditPaymentError> {
    guard let amount, amount > 0.0 else {
      return .failure(.moneyAmountCannotBeEmptyOrZero)
    }
    guard let category else {
      return .failure(.categoryEmpty)
    }
    let updatedPayment: Payment = {
      if let edittedPayment = state.edittedPayment {
        let updatedPayment = edittedPayment
          .updated(amount: amount, category: category, note: note)
        return updatedPayment
      } else {
        return .init(
          accountId: state.selectedAccount.id,
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
