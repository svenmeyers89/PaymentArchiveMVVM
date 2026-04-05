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
    fileprivate(set) var isDemoMode: Bool
  }

  private let broadcaster: MainBroadcaster<State?> = .init(value: nil)
  
  var currentState: State? {
    broadcaster.value
  }

  // Generate a stream for each new consumer
  func makeStateStream() -> AsyncStream<State?> {
    broadcaster.makeStream()
  }

  private let persistenceStore: PersistenceStore
  private let demoDataStoreConfiguration: DemoDataStoreConfiguration

  private var activeDataStore: PersistenceStore {
    if currentState?.isDemoMode == true {
      return demoDataStoreConfiguration.dataStore
    } else {
      return persistenceStore
    }
  }
  
  init(
    persistanceStore: PersistenceStore,
    demoDataStoreConfiguration: DemoDataStoreConfiguration
  ) {
    self.persistenceStore = persistanceStore
    self.demoDataStoreConfiguration = demoDataStoreConfiguration
  }
  
  func loadData() async throws {
    try await loadInitialState(isDemoMode: false)
  }
  
  private func loadInitialState(isDemoMode: Bool) async throws {
     let dataStore: PersistenceStore = {
      if isDemoMode {
        demoDataStoreConfiguration.dataStore
      } else {
        persistenceStore
      }
    }()

    let accounts = try await dataStore.loadAllAccounts()

    let selectedAccount: Account? = accounts.first

    let accountPayments: [Payment]
    if let selectedAccount {
      accountPayments = try await dataStore.loadPayments(accountId: selectedAccount.id)
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
      payments: payments,
      isDemoMode: isDemoMode
    )
    broadcaster.value = state
  }

  func enterDemoMode() async throws {
    // TODO: Add cache to do this only once!
    try await demoDataStoreConfiguration.dataStoreSeeder.seedDemoData(into: demoDataStoreConfiguration.dataStore)
    broadcaster.value = nil
    try await loadInitialState(isDemoMode: true)
  }

  func exitDemoMode() async throws {
    broadcaster.value = nil
    try await loadInitialState(isDemoMode: false)
  }
}

extension PaymentArchive: EditPaymentDataManager {
  func save(payment: Payment) async throws {
    try await activeDataStore.savePayment(payment)

    let payments = try await activeDataStore.loadPayments(accountId: payment.accountId)

    var updatedState: State? = currentState
    updatedState?.payments[payment.accountId] = payments
    broadcaster.value = updatedState
  }
}

extension PaymentArchive: EditAccountDataManager {
  func save(account: Account) async throws {
    try await activeDataStore.saveAccount(account)

    var updatedState = currentState
    updatedState?.accounts[account.id] = account
    if updatedState?.accounts.count == 1 {
      updatedState?.selectedAccountId = account.id
    }
    broadcaster.value = updatedState
  }
}
