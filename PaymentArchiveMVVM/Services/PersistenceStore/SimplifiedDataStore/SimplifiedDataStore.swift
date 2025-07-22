//
//  SimplifiedDataStore.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

enum SimplifiedDataSourceError: Error {
  case accountNotFound(id: String)
}

actor SimplifiedDataStore {
  private var accounts: [String: Account] = [:]
  private var payments: [String: Payment] = [:]
  
  init(accounts: [Account], payments: [Payment]) {
    self.accounts = accounts.reduce([:], { partialResult, account in
      var updatedDict = partialResult
      updatedDict[account.id] = account
      return updatedDict
    })
    self.payments = payments.reduce([:], { partialResult, payment in
      var updatedDict = partialResult
      updatedDict[payment.id] = payment
      return updatedDict
    })
  }
}

extension SimplifiedDataStore: PersistenceStore {
  func loadAllAccounts() async throws -> [Account] {
    accounts.values
      .sorted(by: { $0.selectedAt > $1.selectedAt })
  }

  func loadPayments(accountId: String) async throws -> [Payment] {
    guard let account = accounts[accountId] else {
      throw SimplifiedDataSourceError.accountNotFound(id: accountId)
    }
    let payments: [Payment] = account.paymentIds.compactMap { self.payments[$0] }
    return payments
  }

  func saveAccount(_ account: Account) async throws {
    accounts[account.id] = account
  }

  func savePayment(_ payment: Payment) async throws {
    guard var account = accounts[payment.accountId] else {
      throw SimplifiedDataSourceError.accountNotFound(id: payment.accountId)
    }
    if !account.paymentIds.contains(where: { $0 == payment.id }) {
      account.paymentIds.append(payment.id)
    }
    accounts[account.id] = account
  }
}
