//
//  Untitled.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

struct Payment: Equatable, Sendable {
  let id: String
  let createdAt: Date
  let accountId: String
  var amountMinorUnits: Int
  var category: Category
  var note: String?

  init(
    id: String = UUID().uuidString,
    createdAt: Date = Date(),
    accountId: String,
    amountMinorUnits: Int,
    category: Category,
    note: String? = nil
  ) {
    self.id = id
    self.createdAt = createdAt
    self.accountId = accountId
    self.amountMinorUnits = amountMinorUnits
    self.category = category
    self.note = note
  }
}
