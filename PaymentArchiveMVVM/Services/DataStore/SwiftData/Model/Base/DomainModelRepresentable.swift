//
//  DomainModelRepresentable.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 16.01.2026..
//

/// By conforming to this protocol, data store models become handlers for two-way mapping
///
/// Note: data store model @Relationship properties require special handling at data store level during creation.
/// As for other actions, the @Relationship attributes automatically keep the DB context consistent.
protocol DomainModelRepresentable {
  associatedtype DomainModel
  associatedtype DTO: DomainModelDTO where DTO.DomainModel == DomainModel

  init(domain: DTO)

  // SwiftData is optimized for mutations, not churn.
  // That's why we rather update the existing model but to delete it and insert a new one
  func update(with domain: DTO)
  
  func toDomain() throws -> DomainModel
}
