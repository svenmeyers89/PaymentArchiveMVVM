//
//  PaymentDTO.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 16.01.2026..
//

import Foundation

struct PaymentDTO: DomainModelDTO {
  typealias DomainModel = Payment
  
  let id: String
  let createdAt: Date
  let amountMinorUnits: Int
  let category: String
  let note: String?
  
  init(domainModel: Payment) {
    self.id = domainModel.id
    self.createdAt = domainModel.createdAt
    self.amountMinorUnits = domainModel.amountMinorUnits
    self.category = domainModel.category.rawValue
    self.note = domainModel.note
  }
}
