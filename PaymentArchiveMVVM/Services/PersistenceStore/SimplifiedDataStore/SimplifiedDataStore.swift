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
  private var accounts: [String: Account] = [:] // // accountId -> Account
  private var payments: [String: [String: Payment]] = [:] // accountId -> Payments
  
  init(accounts: [Account], payments: [String: [String: Payment]]) {
    self.accounts = accounts.reduce([:], { partialResult, account in
      var updatedDict = partialResult
      updatedDict[account.id] = account
      return updatedDict
    })
    self.payments = payments
  }
}

extension SimplifiedDataStore: PersistenceStore {
  func loadAllAccounts() async throws -> [Account] {
    accounts.values
      .sorted(by: { $0.selectedAt > $1.selectedAt })
  }

  func loadPayments(accountId: String) async throws -> [Payment] {
    let payments: [String: Payment] = payments[accountId] ?? [:]
    return payments.values.sorted(by: { $0.createdAt > $1.createdAt })
  }

  func saveAccount(_ account: Account) async throws {
    accounts[account.id] = account
  }

  func savePayment(_ payment: Payment) async throws {
    var accountPayments: [String: Payment] = payments[payment.accountId] ?? [:]
    accountPayments[payment.id] = payment
    self.payments[payment.accountId] = accountPayments
  }
  
  func deleteAccount(accountId: String) async throws {
    self.accounts[accountId] = nil
    self.payments.removeValue(forKey: accountId)
  }
  
  func deletePayments(paymentIds: [String]) async throws {
    var updatedPaymnets: [String: [String: Payment]] = [:]
    for var (accountId, accountPayments) in payments {
      for paymentId in paymentIds {
        accountPayments.removeValue(forKey: paymentId)
      }
      updatedPaymnets[accountId] = accountPayments
    }
    payments = updatedPaymnets
  }
}
