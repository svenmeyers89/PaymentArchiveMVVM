//
//  EditAccountViewModel.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.09.2025..
//

import Observation

@MainActor @Observable
final class EditAccountViewModel {
  private let useCase: EditAccountUseCase
  private let dataManager: EditAccountDataManager
  
  var accountName: String
  var currencyCode: String
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
      self.currencyCode = ""
      self.useBiometry = false
    case .editAccount(let account):
      self.accountName = account.name
      self.currencyCode = account.currency.code
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
    guard !currencyCode.isEmpty else {
      return .failure(EditAccountError.currencyEmpty)
    }
    guard currencyCode.count == 3 else {
      return .failure(EditAccountError.currencyNotValid)
    }

    do {
      let updatedAccount: Account = {
        switch useCase {
        case .addNewAccount:
          return Account(
            name: accountName,
            currency:
              Currency.getPredefined(withCode: currencyCode) ??
              Currency(code: currencyCode, minorUnitExponent: 2), // TODO: Fix this!
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
