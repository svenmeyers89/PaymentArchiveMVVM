//
//  PaymentCategory.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

extension Payment {
  enum Category: String, CaseIterable, Sendable {
    case groceries
    case accommodation
    case restaurantsAndBars
    case utilities
    case transport
    case shopping
    case healthcare
    case presents
  }
}
