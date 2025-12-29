//
//  PaymentArchiveMVVMApp.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct UserDefaultsKeys {
  static let selectedThemeID = "SelectedThemeID"
}

actor DependencyManager {
  private let persistenceStore: PersistenceStore

  init(persistenceStore: PersistenceStore) {
    self.persistenceStore = persistenceStore
  }
  
  @MainActor
  private lazy var paymentArchive: PaymentArchive = {
    .init(persistanceStore: persistenceStore)
  }()
  
  @MainActor
  lazy var sceneFactory: SceneFactory = {
    .init(paymentArchive: paymentArchive)
  }()
}

extension DependencyManager {
  static let mockedWithEmptyStore: DependencyManager = .init(persistenceStore: SimplifiedDataStore.empty)
  static let mockedWithPopulatedStore: DependencyManager = .init(persistenceStore: SimplifiedDataStore.singleAccountWithMultiplePayments)
}

@main
struct PaymentArchiveMVVMApp: App {
  @AppStorage(UserDefaultsKeys.selectedThemeID) private var selectedThemeID: String = Theme.defaultValue.rawValue
  
  let dependencyManager: DependencyManager = .mockedWithEmptyStore

  var body: some Scene {
    WindowGroup {
      dependencyManager
        .sceneFactory
        .buildPaymentArchiveScene()
        .environment(\.theme, Theme(rawValue: selectedThemeID) ?? Theme.defaultValue)
        .environment(\.setTheme) { newTheme in
          selectedThemeID = newTheme.rawValue
        }
        .environment(\.sceneFactory, dependencyManager.sceneFactory)
    }
  }
}
