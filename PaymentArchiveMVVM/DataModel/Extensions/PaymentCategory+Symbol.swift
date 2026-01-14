//
//  PaymentCategory+Symbol.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 14.01.2026..
//

extension Payment.Category {
  var symbolName: String {
    switch self {
    case .groceries:
      return "basket"
    case .accommodation:
      return "building"
    case .restaurantsAndBars:
      return "fork.knife"
    case .utilities:
      return "lightbulb.max"
    case .transport:
      return "car"
    case .shopping:
      return "cart"
    case .healthcare:
      return "staroflife"
    case .presents:
      return "gift"
    }
  }
}
