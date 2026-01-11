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

protocol DomainModelDTO {
  associatedtype DomainModel
  init(domainModel: DomainModel)
}

protocol DomainModelRepresentable {
  associatedtype DomainModel
  associatedtype DTO: DomainModelDTO where DTO.DomainModel == DomainModel

  init(domain: DTO)

  // SwiftData is optimized for mutations, not churn.
  // That's why we rather update the existing model but to delete it and insert a new one
  func update(with domain: DTO)
  
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

struct AccountDTO: DomainModelDTO {
  typealias DomainModel = Account
  
  let id: String
  let selectedAt: TimeInterval
  let name: String
  let currencyCode: String
  let useBiometry: Bool
  
  init(domainModel: Account) {
    self.id = domainModel.id
    self.selectedAt = domainModel.selectedAt
    self.name = domainModel.name
    self.currencyCode = domainModel.currency.code
    self.useBiometry = domainModel.useBiometry
  }
}

extension AccountRecord: DomainModelRepresentable {
  typealias DomainModel = Account
  typealias DTO = AccountDTO
  
  convenience init(domain: AccountDTO) {
    self.init(
      id: domain.id,
      selectedAt: domain.selectedAt,
      name: domain.name,
      currencyCode: domain.currencyCode,
      useBiometry: domain.useBiometry
    )
  }
  
  func update(with domain: AccountDTO) {
    self.selectedAt = domain.selectedAt
    self.name = domain.name
    self.currencyCode = domain.currencyCode
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

struct PaymentDTO: DomainModelDTO {
  typealias DomainModel = Payment
  
  let id: String
  let timestamp: TimeInterval
  let amountMinorUnits: Int
  let category: String
  let note: String?
  
  init(domainModel: Payment) {
    self.id = domainModel.id
    self.timestamp = domainModel.timestamp
    self.amountMinorUnits = domainModel.amountMinorUnits
    self.category = domainModel.category.rawValue
    self.note = domainModel.note
  }
}

extension PaymentRecord: DomainModelRepresentable {
  typealias DomainModel = Payment
  typealias DTO = PaymentDTO
  
  convenience init(domain: PaymentDTO) {
    self.init(
      id: domain.id,
      timestamp: domain.timestamp,
      amountMinorUnits: domain.amountMinorUnits,
      category: domain.category,
      note: domain.note
    )
  }

  func update(with domain: PaymentDTO) {
    self.timestamp = domain.timestamp
    self.amountMinorUnits = domain.amountMinorUnits
    self.category = domain.category
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
    let accountDto = AccountDTO(domainModel: account)
    if let existingAccountRecord = try loadAccountRecord(accountId: account.id) {
      existingAccountRecord.update(with: accountDto)
    } else {
      let accountRecord = AccountRecord(domain: accountDto)
      context.insert(accountRecord)
    }

    try context.save()
  }
  
  func savePayment(_ payment: Payment) async throws {
    let paymentDTO = PaymentDTO(domainModel: payment)
    if let existingPaymentRecord = try loadPaymentRecords(paymentIds: [payment.id]).first {
      existingPaymentRecord.update(with: paymentDTO)
    } else {
      guard let accountRecord = try loadAccountRecord(accountId: payment.accountId) else {
        throw SwiftDataPersistenceStoreError.invalidDataStoreState
      }
      let paymentRecord = PaymentRecord(domain: paymentDTO)
      // Since these are inverse relationships, only one of two two following lines is enough
      // Leaving both for clarity
      accountRecord.payments.append(paymentRecord)
      paymentRecord.account = accountRecord
      context.insert(paymentRecord)
    }

    try context.save()
  }
  
  func deleteAccount(accountId: String) async throws {
    guard let accountRecord = try loadAccountRecord(accountId: accountId) else {
      print("SwiftDataPersistenceStore: Account \(accountId) not found")
      return
    }
    
    // Deleting account like this will also delete all related payments
    // This happens automatically due to the .cascade attribute of the account->payments relationship
    context.delete(accountRecord)
    
    try context.save()
  }

  func deletePayments(paymentIds: [String]) async throws {
    guard !paymentIds.isEmpty else { return }

    let paymentRecords = try loadPaymentRecords(paymentIds: paymentIds)

    // Deleting payments like this automatically removes them from the related account's payments collection
    // SwiftData maintains inverse relationship consistency for managed models
    for payment in paymentRecords {
      context.delete(payment)
    }

    try context.save()
  }
  
  // MARK: Helper
  
  private func loadAccountRecord(accountId: String) throws -> AccountRecord? {
    let fetchAccount = FetchDescriptor<AccountRecord>(predicate: #Predicate { accountId == $0.id })
    return try context.fetch(fetchAccount).first
  }
  
  private func loadPaymentRecords(paymentIds: [String]) throws -> [PaymentRecord] {
    let descriptor = FetchDescriptor<PaymentRecord>(
      predicate: #Predicate { payment in
        paymentIds.contains(payment.id)
      }
    )
    
    let paymentRecords = try context.fetch(descriptor)
    return paymentRecords
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
