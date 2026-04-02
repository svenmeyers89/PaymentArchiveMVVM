//
//  DependencyManager.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 14.01.2026..
//

actor DependencyManager {
  private let persistenceStore: PersistenceStore
  private let demoDataStoreConfiguration: DemoDataStoreConfiguration

  init(
    persistenceStore: PersistenceStore,
    demoDataStoreConfiguration: DemoDataStoreConfiguration
  ) {
    self.persistenceStore = persistenceStore
    self.demoDataStoreConfiguration = demoDataStoreConfiguration
  }
  
  @MainActor
  private lazy var paymentArchive: PaymentArchive = {
    .init(
      persistanceStore: self.persistenceStore,
      demoDataStoreConfiguration: self.demoDataStoreConfiguration
    )
  }()
  
  @MainActor
  lazy var screenFactory: ScreenFactory = {
    .init(paymentArchive: paymentArchive)
  }()
}
