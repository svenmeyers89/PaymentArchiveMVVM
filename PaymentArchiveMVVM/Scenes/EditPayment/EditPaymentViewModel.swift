//
//  EditPaymentViewModel.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

protocol EditPaymentDataManager: Sendable {
  func save(payment: Payment) async throws
}

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

enum EditPaymentUseCase {
  case addNewPayment(selectedAccountId: String)
  case editPayment(Payment)
}

@MainActor @Observable
final class EditPaymentViewModel {
  var amountMinorUnits: Int
  var category: Payment.Category?
  var note: String?
  
  private let useCase: EditPaymentUseCase
  let currency: Currency
  let categories: [Payment.Category]

  nonisolated private let dataManager: EditPaymentDataManager

  init(
    useCase: EditPaymentUseCase,
    currency: Currency,
    categories: [Payment.Category],
    dataManager: EditPaymentDataManager
  ) {
    self.useCase = useCase
    self.categories = categories
    self.currency = currency

    switch useCase {
    case .addNewPayment:
      self.amountMinorUnits = 0
      self.category = nil
      self.note = nil
    case .editPayment(let payment):
      self.amountMinorUnits = payment.amountMinorUnits
      self.category = payment.category
      self.note = payment.note
    }

    self.dataManager = dataManager
  }
  
  func savePayment() async -> Result<Void, EditPaymentError> {
    guard amountMinorUnits > 0 else {
      return .failure(.moneyAmountCannotBeEmptyOrZero)
    }
    guard let category else {
      return .failure(.categoryEmpty)
    }
    let updatedPayment: Payment = {
      switch useCase {
      case .addNewPayment(let selectedAccountId):
        return .init(
          accountId: selectedAccountId,
          amountMinorUnits: amountMinorUnits,
          category: category,
          note: note
        )
      case .editPayment(let payment):
        let updatedPayment = payment.updated(
          amountMinorUnits: amountMinorUnits, category: category, note: note
        )
        return updatedPayment
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
  func updated(amountMinorUnits: Int, category: Payment.Category, note: String?) -> Payment {
    var updatedPayment = self
    updatedPayment.amountMinorUnits = amountMinorUnits
    updatedPayment.category = category
    updatedPayment.note = note
    return updatedPayment
  }
}
