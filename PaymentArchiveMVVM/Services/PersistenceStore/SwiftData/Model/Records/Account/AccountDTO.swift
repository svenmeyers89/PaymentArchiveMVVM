//
//  AccountDTO.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 16.01.2026..
//

import Foundation

struct AccountDTO: DomainModelDTO {
  typealias DomainModel = Account
  
  let id: String
  let selectedAt: Date
  let name: String
  let currencyCode: String
  let useBiometry: Bool
  
  init(domainModel: Account) {
    self.id = domainModel.id
    self.selectedAt = domainModel.selectedAt
    self.name = domainModel.name
    self.currencyCode = domainModel.currency.code
    self.useBiometry = domainModel.useBiometry
  }
}
