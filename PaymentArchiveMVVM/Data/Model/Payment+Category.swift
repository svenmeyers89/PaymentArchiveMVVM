//
//  Payment+Category.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation
import UIKit

extension Payment {
  enum Category: String, CaseIterable, Sendable {
    case groceries
    case accomodation
    case restaurantsAndBars
    case utilities
    case transport
    case shopping
    case healthcare
    case presents
    
    var symbolName: String {
      switch self {
      case .groceries:
        return "basket"
      case .accomodation:
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
    
    var name: String {
      rawValue
    }
  }
}
