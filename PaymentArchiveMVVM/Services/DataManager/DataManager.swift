//
//  DataManager.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 21.08.2025..
//

import Observation

@MainActor @Observable
final class PaymentArchive: Sendable {
  private(set) var state: State?
  
  private let persistanceStore: PersistenceStore
  
  init(persistanceStore: PersistenceStore) {
    self.persistanceStore = persistanceStore
  }
  
  struct State {
    fileprivate(set) var selectedAccountId: String?
    fileprivate(set) var accounts: [String: Account]
    fileprivate(set) var payments: [String: [Payment]]

    static let empty = State(selectedAccountId: nil, accounts: [:], payments: [:])
    
    var selectedAccount: Account? {
      guard let selectedAccountId else { return nil }
      return accounts[selectedAccountId]
    }
  }
  
  func loadInitialState() async throws {
    let accounts = try await persistanceStore.loadAllAccounts()

    let selectedAccount: Account? = accounts.first

    let accountPayments: [Payment]
    if let selectedAccount {
      accountPayments = try await persistanceStore.loadPayments(accountId: selectedAccount.id)
    } else {
      accountPayments = []
    }

    let payments: [String: [Payment]]
    if let selectedAccountId = selectedAccount?.id {
      payments = [selectedAccountId: accountPayments]
    } else {
      payments = [:]
    }

    let state = PaymentArchive.State(
      selectedAccountId: selectedAccount?.id,
      accounts: Dictionary(uniqueKeysWithValues: accounts.map { ($0.id, $0) }),
      payments: payments
    )
    self.state = state
  }
}

extension PaymentArchive: EditPaymentDataManager {
  func save(payment: Payment) async throws {
    try await persistanceStore.savePayment(payment)

    let payments = try await persistanceStore.loadPayments(accountId: payment.accountId)

    var updatedState: State? = self.state
    updatedState?.payments[payment.accountId] = payments
    self.state = updatedState
  }
}

extension PaymentArchive: EditAccountDataManager {
  func save(account: Account) async throws {
    try await persistanceStore.saveAccount(account)

    var updatedState = self.state
    updatedState?.accounts[account.id] = account
    self.state = updatedState
  }
}
