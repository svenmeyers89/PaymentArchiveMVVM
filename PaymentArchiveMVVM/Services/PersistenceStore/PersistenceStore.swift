//
//  PersistenceStore.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

protocol PersistenceStore: Sendable {
  func loadAllAccounts() async throws -> [Account]
  func loadPayments(accountId: String) async throws -> [Payment]
  func saveAccount(_ account: Account) async throws
  func savePayment(_ payment: Payment) async throws
}
