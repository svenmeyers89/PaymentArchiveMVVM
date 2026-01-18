//
//  DomainModelDTO.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 16.01.2026..
//

// DTO models should provide easy initialization and updating of PersistenceStore models
protocol DomainModelDTO {
  associatedtype DomainModel
  init(domainModel: DomainModel)
}
