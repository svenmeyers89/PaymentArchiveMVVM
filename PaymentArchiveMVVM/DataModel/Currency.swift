//
//  Currency.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 30.12.2025..
//

import Foundation

struct Currency: Equatable, Sendable {
  let code: String
  let minorUnitExponent: Int
  
  init(code: String, minorUnitExponent: Int) {
    self.code = code.uppercased()
    self.minorUnitExponent = minorUnitExponent
  }
}
