//
//  Currency+.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 14.01.2026..
//

import Foundation

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
