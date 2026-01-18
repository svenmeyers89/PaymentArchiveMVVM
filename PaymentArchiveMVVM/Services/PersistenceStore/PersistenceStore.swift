//
//  PersistenceStore.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

protocol PersistenceStore: Sendable {
  // Convention: returns accounts sorted by selectedAt
  func loadAllAccounts() async throws -> [Account]
  
  // Convention: returns payments sorted by createdAt
  func loadPayments(accountId: String) async throws -> [Payment]
  
  func saveAccount(_ account: Account) async throws
  func savePayment(_ payment: Payment) async throws
  func deleteAccount(accountId: String) async throws
  func deletePayments(paymentIds: [String]) async throws
}
