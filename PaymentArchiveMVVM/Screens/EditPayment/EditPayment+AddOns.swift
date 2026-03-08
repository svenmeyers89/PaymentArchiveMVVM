//
//  EditPayment+AddOns.swift
//  PaymentArchiveMVVM
//

protocol EditPaymentDataManager: Sendable {
  func save(payment: Payment) async throws
}

enum EditPaymentUseCase {
  case addNewPayment(selectedAccountId: String)
  case editPayment(Payment)
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
