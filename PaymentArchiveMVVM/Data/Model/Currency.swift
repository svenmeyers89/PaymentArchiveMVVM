//
//  Currency.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 30.12.2025..
//

struct Currency: Equatable, Sendable {
  let code: String
  let minorUnitExponent: Int
  
  init(code: String, minorUnitExponent: Int) {
    self.code = code.uppercased()
    self.minorUnitExponent = minorUnitExponent
  }
}

import Foundation

// MARK: Basic math

extension Currency {
  private var base: Double {
    pow(10, Double(minorUnitExponent))
  }
  
  fileprivate func baseAmount(from amountMinorUnits: Int) -> Double {
    Double(amountMinorUnits) / base
  }
  
  fileprivate func amountMinorUnits(from baseValue: Double) -> Int {
    Int(
      (baseValue * base).rounded(.toNearestOrAwayFromZero)
    )
  }
}

// MARK: Formatting

extension Currency {
  private var numberStyle: FloatingPointFormatStyle<Double> {
    .number
    .precision(.fractionLength(minorUnitExponent))
    .locale(Locale.appLocale)
  }
  
  private var currencyCodeStyle: FloatingPointFormatStyle<Double>.Currency {
    .currency(code: code)
  }

  func string(from amountMinorUnits: Int, appendCurrencyCode: Bool) -> String {
    let baseAmount = baseAmount(from: amountMinorUnits)
    if appendCurrencyCode {
      return baseAmount.formatted(currencyCodeStyle)
    } else {
      return baseAmount.formatted(numberStyle)
    }
  }
  
  func amountMinorUnits(from formattedValue: String) -> Int? {
    guard let baseAmount =
      (try? Double(formattedValue, format: numberStyle)) ??
      (try? Double(formattedValue, format: currencyCodeStyle)) else {
      return nil
    }
    return amountMinorUnits(from: baseAmount)
  }
}

// MARK: Predefined

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
