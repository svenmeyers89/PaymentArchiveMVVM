//
//  DependencyManager+Variants.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 14.01.2026..
//

extension DependencyManager {
  static let swiftDataStore: DependencyManager = .init(persistenceStore: try! SwiftDataPersistenceStore())
  static let mockedWithEmptyStore: DependencyManager = .init(persistenceStore: SimplifiedDataStore.empty)
  static let mockedWithPopulatedStore: DependencyManager = .init(persistenceStore: SimplifiedDataStore.singleAccountWithMultiplePayments)
}
