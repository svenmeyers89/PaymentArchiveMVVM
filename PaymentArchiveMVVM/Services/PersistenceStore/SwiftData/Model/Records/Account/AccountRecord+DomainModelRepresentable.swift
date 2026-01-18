//
//  AccountRecord+DomainModelRepresentable.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 16.01.2026..
//

extension AccountRecord: DomainModelRepresentable {
  typealias DomainModel = Account
  typealias DTO = AccountDTO
  
  convenience init(domain: AccountDTO) {
    self.init(
      id: domain.id,
      selectedAt: domain.selectedAt,
      name: domain.name,
      currencyCode: domain.currencyCode,
      useBiometry: domain.useBiometry
    )
  }
  
  func update(with domain: AccountDTO) {
    self.selectedAt = domain.selectedAt
    self.name = domain.name
    self.currencyCode = domain.currencyCode
    self.useBiometry = domain.useBiometry
  }
  
  func toDomain() throws -> Account {
    guard let currency = Currency.getPredefined(withCode: currencyCode) else {
      throw SwiftDataPersistenceStoreError.missingDomainParameters
    }
    return .init(
      id: id,
      selectedAt: selectedAt,
      name: name,
      currency: currency,
      useBiometry: useBiometry
    )
  }
}
