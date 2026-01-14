//
//  Currency+Math.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 14.01.2026..
//

import Foundation

extension Currency {
  private var base: Double {
    pow(10, Double(minorUnitExponent))
  }
  
  func baseAmount(from amountMinorUnits: Int) -> Double {
    Double(amountMinorUnits) / base
  }
  
  func amountMinorUnits(from baseValue: Double) -> Int {
    Int(
      (baseValue * base).rounded(.toNearestOrAwayFromZero)
    )
  }
}
