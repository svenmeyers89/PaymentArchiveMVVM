//
//  DependencyManager+Variants.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 14.01.2026..
//

extension DependencyManager {
  static let live: DependencyManager = {
    do {
      let locationResolver: SwiftDataStoreLocationResolver = ApplicationSandboxSwiftDataStoreLocationResolver()
      let persistenceStore: PersistenceStore = try SwiftDataPersistenceStore(
        dataBaseConfiguration: .persisted(
          locationResolver: locationResolver
        )
      )

      let demoDataStore: PersistenceStore = try SwiftDataPersistenceStore(dataBaseConfiguration: .inMemory)
      let demoDataStoreSeeder: DemoDataStoreSeeder = RandomizedDataStoreSeeder()
      let demoDataStoreConfiguration: DemoDataStoreConfiguration = .init(
        dataStore: demoDataStore,
        dataStoreSeeder: demoDataStoreSeeder
      )

      return DependencyManager(
        persistenceStore: persistenceStore,
        demoDataStoreConfiguration: demoDataStoreConfiguration
      )
    } catch {
      fatalError("Failed to initialize SwiftDataPersistenceStore: \(error)")
    }
  }()

  private static let mockedDemoDataStoreConfiguration: DemoDataStoreConfiguration = .init(
    dataStore: SimplifiedDataStore.demo,
    dataStoreSeeder: RandomizedDataStoreSeeder()
  )
  
  static let mockedWithEmptyStore: DependencyManager = .init(
    persistenceStore: SimplifiedDataStore.empty,
    demoDataStoreConfiguration: mockedDemoDataStoreConfiguration
  )

  static let mockedWithPopulatedStore: DependencyManager = .init(
    persistenceStore: SimplifiedDataStore.singleAccountWithMultiplePayments,
    demoDataStoreConfiguration: mockedDemoDataStoreConfiguration
  )
}
