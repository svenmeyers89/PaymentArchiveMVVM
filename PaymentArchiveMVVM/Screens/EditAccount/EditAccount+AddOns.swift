//
//  EditAccount+AddOns.swift
//  PaymentArchiveMVVM
//

protocol EditAccountDataManager: Sendable {
  func save(account: Account) async throws
}

enum EditAccountUseCase {
  case addNewAccount
  case editAccount(Account)
}

enum EditAccountError: Error {
  case accountNameEmpty
  case currencyEmpty
  case currencyNotValid
  case saveAccountFailed(Error)

  var message: String {
    switch self {
    case .accountNameEmpty:
      return "Account name cannot be empty"
    case .currencyEmpty:
      return "Currency cannot be empty"
    case .currencyNotValid:
      return "Currency must be exactly 3 characters long"
    case .saveAccountFailed(let error):
      return "Saving account failed: \(error)"
    }
  }
}
