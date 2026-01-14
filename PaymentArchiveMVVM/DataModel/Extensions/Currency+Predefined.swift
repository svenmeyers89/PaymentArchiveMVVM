//
//  Currency+Predefined.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 14.01.2026..
//

// Consider predefining currencies in a plist
extension Currency {
  static let usd = Currency(code: "USD", minorUnitExponent: 2)
  static let eur = Currency(code: "EUR", minorUnitExponent: 2)
  static let yen = Currency(code: "JPY", minorUnitExponent: 0)
  static let gbp = Currency(code: "GBP", minorUnitExponent: 2)

  static let predefined: [Currency] = [usd, eur, yen, gbp]

  static func getPredefined(withCode code: String) -> Currency? {
    predefined.first { $0.code == code }
  }
}
