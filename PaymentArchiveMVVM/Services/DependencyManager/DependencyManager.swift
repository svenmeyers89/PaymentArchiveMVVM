//
//  DependencyManager.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 14.01.2026..
//

actor DependencyManager {
  private let persistenceStore: PersistenceStore

  init(persistenceStore: PersistenceStore) {
    self.persistenceStore = persistenceStore
  }
  
  @MainActor
  private lazy var paymentArchive: PaymentArchive = {
    .init(persistanceStore: self.persistenceStore)
  }()
  
  @MainActor
  lazy var sceneFactory: SceneFactory = {
    .init(paymentArchive: paymentArchive)
  }()
}
