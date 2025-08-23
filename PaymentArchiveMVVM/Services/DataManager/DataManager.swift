//
//  DataManager.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 21.08.2025..
//

import Observation

extension PaymentArchive {
  struct State {
    let selectedAccountId: String?
    let accounts: [String: Account]
    let payments: [String: [Payment]]

    static let empty = State(selectedAccountId: nil, accounts: [:], payments: [:])
    
    func updating(accounts: [Account]) -> State {
      var updatedAccounts = self.accounts
      accounts.forEach { account in
        updatedAccounts[account.id] = account
      }
      return .init(
        selectedAccountId: selectedAccountId,
        accounts: updatedAccounts,
        payments: payments
      )
    }
    
    func updating(payments: [Payment]) -> State {
      var updatedPayments = self.payments
      payments.forEach { payment in
        var accountPayments = updatedPayments[payment.accountId, default: []]

        if let index = accountPayments.firstIndex(where: { $0.id == payment.id }) {
          accountPayments[index] = payment
        } else {
          let insertionIndex = accountPayments.firstIndex { $0.timestamp < payment.timestamp } ?? 0
          accountPayments.insert(payment, at: insertionIndex)
        }
        updatedPayments[payment.accountId] = accountPayments
      }

      return .init(
        selectedAccountId: selectedAccountId,
        accounts: accounts,
        payments: updatedPayments
      )
    }
  }
}

@MainActor @Observable
final class PaymentArchive: Sendable {
  private(set) var state: State = .empty

  private let persistanceStore: PersistenceStore

  init(persistanceStore: PersistenceStore) {
    self.persistanceStore = persistanceStore
  }
  
  func loadInitialState() async throws {
    let accounts = try await persistanceStore.loadAllAccounts()
    let selectedAccount = {
      accounts.sorted(by: { $0.selectedAt > $1.selectedAt }).first
    }()
    if let selectedAccount {
      let payments = try await persistanceStore.loadPayments(accountId: selectedAccount.id)
      let state = PaymentArchive.State(
        selectedAccountId: selectedAccount.id,
        accounts: Dictionary(uniqueKeysWithValues: accounts.map { ($0.id, $0) }),
        payments: [selectedAccount.id: payments]
      )
      self.state = state
    }
  }

  func save(payment: Payment) async throws {
    try await persistanceStore.savePayment(payment)
    
    let updatedState = self.state.updating(payments: [payment])
    self.state = updatedState
  }
  
  func save(account: Account) async throws {
    try await persistanceStore.saveAccount(account)

    let updatedState = self.state.updating(accounts: [account])
    self.state = updatedState
  }
}
