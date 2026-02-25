//
//  DataManager.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 21.08.2025..
//

import AsyncOperators
import Foundation
import Observation

@MainActor
final class PaymentArchive: Sendable {
  struct State: Equatable, Sendable {
    fileprivate(set) var selectedAccountId: String?
    fileprivate(set) var accounts: [String: Account]
    fileprivate(set) var payments: [String: [Payment]]
  }

  private let broadcaster: MainBroadcaster<State?> = .init(value: nil)
  
  var currentState: State? {
    broadcaster.value
  }
  
  // Generate a stream for each new consumer
  func makeStateStream() -> AsyncStream<State?> {
    broadcaster.makeStream()
  }

  private let persistanceStore: PersistenceStore
  
  init(persistanceStore: PersistenceStore) {
    self.persistanceStore = persistanceStore
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
    broadcaster.value = state
  }
}

extension PaymentArchive: EditPaymentDataManager {
  func save(payment: Payment) async throws {
    try await persistanceStore.savePayment(payment)

    let payments = try await persistanceStore.loadPayments(accountId: payment.accountId)

    var updatedState: State? = currentState
    updatedState?.payments[payment.accountId] = payments
    broadcaster.value = updatedState
  }
}

extension PaymentArchive: EditAccountDataManager {
  func save(account: Account) async throws {
    try await persistanceStore.saveAccount(account)

    var updatedState = currentState
    updatedState?.accounts[account.id] = account
    if updatedState?.accounts.count == 1 {
      updatedState?.selectedAccountId = account.id
    }
    broadcaster.value = updatedState
  }
}
