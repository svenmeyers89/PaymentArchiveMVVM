//
//  PredefinedCurrency.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.09.2025..
//

enum PrederfinedCurrency: String, CaseIterable {
  case eur
  case usd
  case yen
  case gbp
  
  var symbol: String {
    switch self {
    case .eur:
      return "€"
    case .usd:
      return "$"
    case .yen:
      return "¥"
    case .gbp:
      return "£"
    }
  }
}
