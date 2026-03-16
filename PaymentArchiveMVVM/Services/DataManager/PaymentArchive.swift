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

  private enum Mode {
    case live
    case demo
  }

  private let broadcaster: MainBroadcaster<State?> = .init(value: nil)
  
  var currentState: State? {
    broadcaster.value
  }
  
  var isInDemoMode: Bool {
    mode == .demo
  }

  // Generate a stream for each new consumer
  func makeStateStream() -> AsyncStream<State?> {
    broadcaster.makeStream()
  }

  private let livePersistenceStore: PersistenceStore
  private var demoPersistenceStore: PersistenceStore?
  private var mode: Mode = .live
  private var cachedState: [Mode: PaymentArchive.State] = [:]

  private var activeStore: PersistenceStore {
    switch mode {
    case .live:
      return livePersistenceStore
    case .demo:
      if let demoPersistenceStore {
        return demoPersistenceStore
      }
      let demoStore = SimplifiedDataStore.demo()
      demoPersistenceStore = demoStore
      return demoStore
    }
  }
  
  init(persistanceStore: PersistenceStore) {
    self.livePersistenceStore = persistanceStore
  }
  
  func loadInitialState() async throws {
    let accounts = try await activeStore.loadAllAccounts()

    let selectedAccount: Account? = accounts.first

    let accountPayments: [Payment]
    if let selectedAccount {
      accountPayments = try await activeStore.loadPayments(accountId: selectedAccount.id)
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

  func enterDemoMode() async throws {
    mode = .demo
    cachedState[.live] = broadcaster.value
    broadcaster.value = nil
    try await loadInitialState()
  }

  func exitDemoMode() async throws {
    mode = .live
    if let cachedLiveState = cachedState[.live] {
      broadcaster.value = cachedLiveState
    } else {
      broadcaster.value = nil
      try await loadInitialState()
    }
  }
}

extension PaymentArchive: EditPaymentDataManager {
  func save(payment: Payment) async throws {
    try await activeStore.savePayment(payment)

    let payments = try await activeStore.loadPayments(accountId: payment.accountId)

    var updatedState: State? = currentState
    updatedState?.payments[payment.accountId] = payments
    broadcaster.value = updatedState
  }
}

extension PaymentArchive: EditAccountDataManager {
  func save(account: Account) async throws {
    try await activeStore.saveAccount(account)

    var updatedState = currentState
    updatedState?.accounts[account.id] = account
    if updatedState?.accounts.count == 1 {
      updatedState?.selectedAccountId = account.id
    }
    broadcaster.value = updatedState
  }
}
