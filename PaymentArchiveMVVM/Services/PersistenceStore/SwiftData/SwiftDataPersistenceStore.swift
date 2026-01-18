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
    let accountRecords = try loadAllAccountRecords()
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
  
  private func loadAllAccountRecords() throws -> [AccountRecord] {
    let descriptor = FetchDescriptor<AccountRecord>(
      sortBy: [SortDescriptor(\.selectedAt, order: .reverse)]
    )
    return try context.fetch(descriptor)
  }
  
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
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )

    let paymentRecords = try context.fetch(descriptor)
    return paymentRecords
  }
}
