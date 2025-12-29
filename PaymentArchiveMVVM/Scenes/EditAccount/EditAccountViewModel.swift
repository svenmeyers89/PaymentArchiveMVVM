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

enum EditAccountUseCase {
  case addNewAccount
  case editAccount(Account)
}

@MainActor @Observable
final class EditAccountViewModel {
  private let useCase: EditAccountUseCase
  private let dataManager: EditAccountDataManager
  
  var accountName: String
  var currency: String
  var useBiometry: Bool

  init(
    useCase: EditAccountUseCase,
    dataManager: EditAccountDataManager
  ) {
    self.useCase = useCase
    self.dataManager = dataManager
    
    switch useCase {
    case .addNewAccount:
      self.accountName = ""
      self.currency = ""
      self.useBiometry = false
    case .editAccount(let account):
      self.accountName = account.name
      self.currency = account.currency
      self.useBiometry = account.useBiometry
    }
  }
  
  var isEdittingExistingAccount: Bool {
    switch useCase {
    case .addNewAccount:
      return false
    case .editAccount:
      return true
    }
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
      let updatedAccount: Account = {
        switch useCase {
        case .addNewAccount:
          return Account(
            name: accountName,
            paymentIds: [],
            currency: currency.uppercased(),
            useBiometry: useBiometry
          )
        case .editAccount(let account):
          let updatedAccount = account.updatedAccount(name: accountName, useBiometry: useBiometry)
          return updatedAccount
        }
      }()
      try await dataManager.save(account: updatedAccount)
      return .success(())
    } catch {
      return .failure(.saveAccountFailed(error))
    }
  }
}

fileprivate extension Account {
  func updatedAccount(name: String, useBiometry: Bool) -> Account {
    var account = self
    account.name = name
    account.useBiometry = useBiometry
    return account
  }
}
