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
    
    var selectedAccount: Account? {
      guard let selectedAccountId else {
        return nil
      }
      return accounts[selectedAccountId]
    }
    
    func updating(accounts: [Account]) -> State {
      var updatedAccounts = self.accounts
      accounts.forEach { account in
        updatedAccounts[account.id] = account
      }
      return .init(
        selectedAccountId: updatedAccounts.values.sorted(by: { $0.selectedAt > $1.selectedAt }).first?.id,
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
  private(set) var state: State?
  
  private let persistanceStore: PersistenceStore
  
  init(persistanceStore: PersistenceStore) {
    self.persistanceStore = persistanceStore
  }
  
  func loadInitialState() async throws {
    let accounts = try await persistanceStore.loadAllAccounts()

    let selectedAccount = accounts.sorted(by: { $0.selectedAt > $1.selectedAt }).first

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
    
    let updatedState = self.state?.updating(payments: [payment])
    self.state = updatedState
  }
}
 
extension PaymentArchive: EditAccountDataManager {
  func save(account: Account) async throws {
    try await persistanceStore.saveAccount(account)

    let updatedState = self.state?.updating(accounts: [account])
    self.state = updatedState
  }
}
