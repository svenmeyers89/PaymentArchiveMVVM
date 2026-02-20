//
//  DependencyManager+Variants.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 14.01.2026..
//

extension DependencyManager {
  static let live: DependencyManager = {
    do {
      let persistenceStore: PersistenceStore = try SwiftDataPersistenceStore(
        dataBaseConfiguration: .persisted(
          locationResolver: ApplicationSandboxSwiftDataStoreLocationResolver()
        )
      )
      return DependencyManager(persistenceStore: persistenceStore)
    } catch {
      fatalError("Failed to initialize SwiftDataPersistenceStore: \(error)")
    }
  }()
  static let mockedWithEmptyStore: DependencyManager = .init(persistenceStore: SimplifiedDataStore.empty)
  static let mockedWithPopulatedStore: DependencyManager = .init(persistenceStore: SimplifiedDataStore.singleAccountWithMultiplePayments)
}
