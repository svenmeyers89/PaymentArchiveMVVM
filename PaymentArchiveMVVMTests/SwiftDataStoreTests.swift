import Foundation
import Testing
@testable import PaymentArchiveMVVM

struct SwiftDataStoreTests {
  @Test("Loads accounts sorted by selectedAt descending")
  func loadAllAccountsSortedBySelectedAtDescending() async throws {
    let store = try SwiftDataStore(dataBaseConfiguration: .inMemory)
    let olderAccount = Account(
      id: "account-1",
      selectedAt: Date(timeIntervalSince1970: 10),
      name: "Older",
      currency: .usd,
      useBiometry: false
    )
    let newerAccount = Account(
      id: "account-2",
      selectedAt: Date(timeIntervalSince1970: 20),
      name: "Newer",
      currency: .eur,
      useBiometry: true
    )

    try await store.saveAccount(olderAccount)
    try await store.saveAccount(newerAccount)

    let loadedAccounts = try await store.loadAllAccounts()
    #expect(loadedAccounts.map { $0.id } == ["account-2", "account-1"])
  }

  @Test("Loads payments sorted by createdAt descending and deletes selected payments")
  func loadPaymentsSortedByCreatedAtDescendingAndDeletePayments() async throws {
    let store = try SwiftDataStore(dataBaseConfiguration: .inMemory)
    let account = Account(
      id: "account-1",
      selectedAt: Date(timeIntervalSince1970: 100),
      name: "Main",
      currency: .usd,
      useBiometry: false
    )
    let olderPayment = Payment(
      id: "payment-1",
      createdAt: Date(timeIntervalSince1970: 10),
      accountId: account.id,
      amountMinorUnits: 100,
      category: .groceries
    )
    let newerPayment = Payment(
      id: "payment-2",
      createdAt: Date(timeIntervalSince1970: 20),
      accountId: account.id,
      amountMinorUnits: 200,
      category: .shopping
    )

    try await store.saveAccount(account)
    try await store.savePayment(olderPayment)
    try await store.savePayment(newerPayment)

    let allPayments = try await store.loadPayments(accountId: account.id)
    #expect(allPayments.map { $0.id } == ["payment-2", "payment-1"])

    try await store.deletePayments(paymentIds: [newerPayment.id])

    let remainingPayments = try await store.loadPayments(accountId: account.id)
    #expect(remainingPayments.map { $0.id } == ["payment-1"])
  }

  @Test("Saving payment without existing account throws invalidDataStoreState")
  func savePaymentWithoutAccountThrowsInvalidDataStoreState() async throws {
    let store = try SwiftDataStore(dataBaseConfiguration: .inMemory)
    let payment = Payment(
      id: "payment-1",
      createdAt: Date(timeIntervalSince1970: 10),
      accountId: "missing-account",
      amountMinorUnits: 100,
      category: .groceries
    )

    do {
      try await store.savePayment(payment)
      Issue.record("Expected savePayment to throw when account does not exist.")
    } catch let error as SwiftDataStoreError {
      #expect(error == .invalidDataStoreState)
    } catch {
      Issue.record("Unexpected error type: \(error)")
    }
  }

  @Test("Persisted configuration writes to provided store URL")
  func persistedConfigurationUsesProvidedStoreURL() async throws {
    let fileManager = FileManager.default
    let locationResolver: SwiftDataStoreLocationResolver =
      ApplicationSandboxSwiftDataStoreLocationResolver(
        fileManager: fileManager,
        cachingType: .temporary
      )
    let store = try SwiftDataStore(dataBaseConfiguration: .persisted(locationResolver: locationResolver))
    
    let storeURL = try locationResolver.storeURL()
    defer {
      let storeDirectoryURL = storeURL.deletingLastPathComponent()
      try? fileManager.removeItem(at: storeDirectoryURL)
    }

    let account = Account(
      id: "account-1",
      selectedAt: Date(timeIntervalSince1970: 10),
      name: "Persisted",
      currency: .usd,
      useBiometry: false
    )
    try await store.saveAccount(account)
    
    #expect(fileManager.fileExists(atPath: storeURL.path))
  }
}
