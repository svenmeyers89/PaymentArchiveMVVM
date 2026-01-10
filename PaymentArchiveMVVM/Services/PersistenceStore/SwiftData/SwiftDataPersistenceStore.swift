//
//  SwiftDataPersistenceStore.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.01.2026..
//

import Foundation
import SwiftData

enum SwiftDataPersistenceStoreError: Error {
  case missingDomainParameters
  case invalidDataStoreState
}

protocol DomainModelRepresentable {
  associatedtype DomainModel
  init(domain: DomainModel)
  func update(with domain: DomainModel)
  func toDomain() throws -> DomainModel
}

@Model
final class AccountRecord {
  @Attribute(.unique) var id: String
  var selectedAt: TimeInterval
  var name: String
  var currencyCode: String
  var useBiometry: Bool
  
  @Relationship(deleteRule: .cascade) var payments: [PaymentRecord] = []
  
  init(
    id: String,
    selectedAt: TimeInterval,
    name: String,
    currencyCode: String,
    useBiometry: Bool
  ) {
    self.id = id
    self.selectedAt = selectedAt
    self.name = name
    self.currencyCode = currencyCode
    self.useBiometry = useBiometry
  }
}

extension AccountRecord: DomainModelRepresentable {
  typealias DomainModel = Account
  
  convenience init(domain: Account) {
    self.init(
      id: domain.id,
      selectedAt: domain.selectedAt,
      name: domain.name,
      currencyCode: domain.currency.code,
      useBiometry: domain.useBiometry
    )
  }
  
  func update(with domain: Account) {
    self.selectedAt = domain.selectedAt
    self.name = domain.name
    self.currencyCode = domain.currency.code
    self.useBiometry = domain.useBiometry
  }
  
  func toDomain() throws -> Account {
    guard let currency = Currency.getPredefined(withCode: currencyCode) else {
      throw SwiftDataPersistenceStoreError.missingDomainParameters
    }
    return .init(
      id: id,
      selectedAt: selectedAt,
      name: name,
      paymentIds: payments.map(\.self.id),
      currency: currency,
      useBiometry: useBiometry
    )
  }
}

@Model
final class PaymentRecord {
  @Attribute(.unique) var id: String
  var timestamp: TimeInterval
  var amountMinorUnits: Int
  var category: String
  var note: String?
  
  @Relationship(inverse: \AccountRecord.payments) var account: AccountRecord?
  
  init(
    id: String,
    timestamp: TimeInterval,
    amountMinorUnits: Int,
    category: String,
    note: String? = nil
  ) {
    self.id = id
    self.timestamp = timestamp
    self.amountMinorUnits = amountMinorUnits
    self.category = category
    self.note = note
  }
}

extension PaymentRecord: DomainModelRepresentable {
  typealias DomainModel = Payment
  
  convenience init(domain: Payment) {
    self.init(
      id: domain.id,
      timestamp: domain.timestamp,
      amountMinorUnits: domain.amountMinorUnits,
      category: domain.category.rawValue,
      note: domain.note
    )
  }

  func update(with domain: Payment) {
    self.timestamp = domain.timestamp
    self.amountMinorUnits = domain.amountMinorUnits
    self.category = domain.category.rawValue
    self.note = domain.note
  }
  
  func toDomain() throws -> Payment {
    guard let accountRecord = account,
          let category = Payment.Category(rawValue: self.category) else {
      throw SwiftDataPersistenceStoreError.missingDomainParameters
    }
    return .init(
      id: id,
      timestamp: timestamp,
      accountId: accountRecord.id,
      amountMinorUnits: amountMinorUnits,
      category: category,
      note: note
    )
  }
}

actor SwiftDataPersistenceStore {
  private let container: ModelContainer
  
  /// Important:
  /// If modelCotext is created on the main thread and called on the background thread, SwiftData complains!
  /// This would happen if we initialized context in the actor's init.
  /// Keep in mind that actor's init is performed on the caller's thread,
  /// which is usually different than the thread assigned to the actor from the system.
  private lazy var context: ModelContext = {
    .init(container)
  }()
  
  init(isStoredInMemoryOnly: Bool = false) throws {
    self.container = try ModelContainer(
      for: AccountRecord.self, PaymentRecord.self,
      configurations: .init(isStoredInMemoryOnly: isStoredInMemoryOnly)
    )
  }
}

extension SwiftDataPersistenceStore: PersistenceStore {
  func loadAllAccounts() async throws -> [Account] {
    let descriptor = FetchDescriptor<AccountRecord>(
      sortBy: [SortDescriptor(\.selectedAt, order: .reverse)]
    )

    let accountRecords = try context.fetch(descriptor)
    return try accountRecords.map { try $0.toDomain() }
  }
  
  func loadPayments(accountId: String) async throws -> [Payment] {
    let paymentRecords = try loadPaymentRecords(accountId: accountId)
    return try paymentRecords.map { try $0.toDomain() }
  }
  
  func saveAccount(_ account: Account) async throws {
    if let existingAccountRecord = try loadAccountRecord(accountId: account.id) {
      existingAccountRecord.update(with: account)
    } else {
      let accountRecord = AccountRecord(domain: account)
      context.insert(accountRecord)
    }

    try context.save()
  }
  
  func savePayment(_ payment: Payment) async throws {
    if let existingPaymentRecord = try loadPaymentRecord(paymentId: payment.id) {
      existingPaymentRecord.update(with: payment)
    } else {
      guard let accountRecord = try loadAccountRecord(accountId: payment.accountId) else {
        throw SwiftDataPersistenceStoreError.invalidDataStoreState
      }
      let paymentRecord = PaymentRecord(domain: payment)
      // Since these are inverse relationships, only one of two two following lines is enough
      // Leaving both for clarity
      accountRecord.payments.append(paymentRecord)
      paymentRecord.account = accountRecord
      context.insert(paymentRecord)
    }

    try context.save()
  }
  
  // MARK: Helper
  
  private func loadAccountRecord(accountId: String) throws -> AccountRecord? {
    let fetchAccount = FetchDescriptor<AccountRecord>(predicate: #Predicate { accountId == $0.id })
    return try context.fetch(fetchAccount).first
  }
  
  private func loadPaymentRecord(paymentId: String) throws -> PaymentRecord? {
    let descriptor = FetchDescriptor<PaymentRecord>(
      predicate: #Predicate { $0.id == paymentId }
    )
    
    let paymentRecords = try context.fetch(descriptor)
    return paymentRecords.first
  }
  
  private func loadPaymentRecords(accountId: String) throws -> [PaymentRecord] {
    let descriptor = FetchDescriptor<PaymentRecord>(
      predicate: #Predicate { $0.account?.id == accountId },
      sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
    )

    let paymentRecords = try context.fetch(descriptor)
    return paymentRecords
  }
}
