//
//  Account.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

struct Account: Equatable, Sendable {
  let id: String
  var selectedAt: TimeInterval
  var name: String
  var paymentIds: [String]
  let currency: Currency
  var useBiometry: Bool

  init(
    id: String = UUID().uuidString,
    selectedAt: TimeInterval = Date().timeIntervalSince1970,
    name: String,
    paymentIds: [String],
    currency: Currency,
    useBiometry: Bool
  ) {
    self.id = id
    self.selectedAt = selectedAt
    self.name = name
    self.paymentIds = paymentIds
    self.currency = currency
    self.useBiometry = useBiometry
  }
}
