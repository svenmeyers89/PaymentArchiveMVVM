//
//  PaymentRecord.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 16.01.2026..
//

import Foundation
import SwiftData

@Model
final class PaymentRecord {
  @Attribute(.unique) var id: String
  var createdAt: Date
  var amountMinorUnits: Int
  var category: String
  var note: String?
  
  @Relationship(inverse: \AccountRecord.payments) var account: AccountRecord?
  
  init(
    id: String,
    createdAt: Date,
    amountMinorUnits: Int,
    category: String,
    note: String? = nil
  ) {
    self.id = id
    self.createdAt = createdAt
    self.amountMinorUnits = amountMinorUnits
    self.category = category
    self.note = note
  }
}
