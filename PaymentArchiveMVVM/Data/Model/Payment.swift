//
//  Untitled.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

struct Payment: Equatable, Sendable {
  let id: String
  let timestamp: TimeInterval
  let accountId: String
  var amount: Float
  var category: Category
  var note: String?

  init(
    id: String = UUID().uuidString,
    timestamp: TimeInterval = Date().timeIntervalSince1970,
    accountId: String,
    amount: Float,
    category: Category,
    note: String? = nil
  ) {
    self.id = id
    self.timestamp = timestamp
    self.accountId = accountId
    self.amount = amount
    self.category = category
    self.note = note
  }
}
