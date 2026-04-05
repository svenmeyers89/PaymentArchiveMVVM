//
//  PaymentRecord+DomainModelRepresentable.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 16.01.2026..
//

extension PaymentRecord: DomainModelRepresentable {
  typealias DomainModel = Payment
  typealias DTO = PaymentDTO
  
  convenience init(domain: PaymentDTO) {
    self.init(
      id: domain.id,
      createdAt: domain.createdAt,
      amountMinorUnits: domain.amountMinorUnits,
      category: domain.category,
      note: domain.note
    )
  }

  func update(with domain: PaymentDTO) {
    self.createdAt = domain.createdAt
    self.amountMinorUnits = domain.amountMinorUnits
    self.category = domain.category
    self.note = domain.note
  }
  
  func toDomain() throws -> Payment {
    guard let accountRecord = account,
          let category = Payment.Category(rawValue: self.category) else {
      throw SwiftDataStoreError.missingDomainParameters
    }
    return .init(
      id: id,
      createdAt: createdAt,
      accountId: accountRecord.id,
      amountMinorUnits: amountMinorUnits,
      category: category,
      note: note
    )
  }
}
