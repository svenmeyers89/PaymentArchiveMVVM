//
//  Account.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

struct Account: Equatable, Sendable {
  let id: String
  var selectedAt: Date
  var name: String
  let currency: Currency
  var useBiometry: Bool

  init(
    id: String = UUID().uuidString,
    selectedAt: Date = Date(),
    name: String,
    currency: Currency,
    useBiometry: Bool
  ) {
    self.id = id
    self.selectedAt = selectedAt
    self.name = name
    self.currency = currency
    self.useBiometry = useBiometry
  }
}
