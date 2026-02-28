//
//  PaymentGroup.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.02.2026..
//

import Foundation

struct PaymentGroup: Equatable, Sendable {
  enum Kind {
    case monthlyStats
    case dailyPayments
  }
  
  let payments: [Payment]
  let currency: Currency
  let kind: Kind
  let totalAmountMinorUnits: Int
  
  init(payments: [Payment] = [],
       currency: Currency, kind: Kind,
       totalAmountMinorUnits: Int = 0) {
    self.payments = payments
    self.currency = currency
    self.kind = kind
    self.totalAmountMinorUnits = totalAmountMinorUnits
  }
  
  var id: String {
    var kindId = "\(kind)"
    if let dateRepresentative = dateRepresentative {
      kindId += "_\(dateRepresentative)"
    }
    return kindId
  }
  
  var dateRepresentative: Date? {
    payments.first?.createdAt
  }
}
