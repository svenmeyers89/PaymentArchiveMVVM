//
//  AccountRecord.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 16.01.2026..
//

import Foundation
import SwiftData

@Model
final class AccountRecord {
  @Attribute(.unique) var id: String
  var selectedAt: Date
  var name: String
  var currencyCode: String
  var useBiometry: Bool
  
  @Relationship(deleteRule: .cascade) var payments: [PaymentRecord] = []
  
  init(
    id: String,
    selectedAt: Date,
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
