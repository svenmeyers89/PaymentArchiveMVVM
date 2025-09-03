//
//  EditAccountViewModel.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.09.2025..
//

import Observation

protocol EditAccountDataManager: Sendable {
  func save(account: Account) async throws
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

@MainActor @Observable
final class EditAccountViewModel {
  private let edittedAccount: Account?
  private let dataManager: EditAccountDataManager
  
  var accountName: String
  var currency: String
  var useBiometry: Bool

  init(
    edittedAccount: Account?,
    dataManager: EditAccountDataManager
  ) {
    self.edittedAccount = edittedAccount
    self.dataManager = dataManager
    self.accountName = edittedAccount?.name ?? ""
    self.currency = edittedAccount?.currency ?? ""
    self.useBiometry = edittedAccount?.useBiometry ?? false
  }
  
  var isEdittingExistingAccount: Bool {
    edittedAccount != nil
  }
  
  var isEditingCurrencyDisabled: Bool {
    isEdittingExistingAccount
  }
  
  func save() async -> Result<Void, EditAccountError> {
    guard !accountName.isEmpty else {
      return .failure(EditAccountError.accountNameEmpty)
    }
    guard !currency.isEmpty else {
      return .failure(EditAccountError.currencyEmpty)
    }
    guard currency.count == 3 else {
      return .failure(EditAccountError.currencyNotValid)
    }

    do {
      let account = Account(
        name: accountName,
        paymentIds: [],
        currency: currency.uppercased(),
        useBiometry: useBiometry
      )
      try await dataManager.save(account: account)
      return .success(())
    } catch {
      return .failure(.saveAccountFailed(error))
    }
  }
}
