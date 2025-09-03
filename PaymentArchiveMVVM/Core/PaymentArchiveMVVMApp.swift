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

@main
struct PaymentArchiveMVVMApp: App {
  @AppStorage(UserDefaultsKeys.selectedThemeID) private var selectedThemeID: String = Theme.defaultValue.rawValue
  
  let sceneFactory: SceneFactory = .init(
    paymentArchive: PaymentArchive(
      persistanceStore: SimplifiedDataStore.empty
    )
  )

  var body: some Scene {
    WindowGroup {
      sceneFactory
        .buildPaymentArchiveScene()
        .environment(\.theme, Theme(rawValue: selectedThemeID) ?? Theme.defaultValue)
        .environment(\.setTheme) { newTheme in
          selectedThemeID = newTheme.rawValue
        }
        .environment(\.sceneFactory, sceneFactory)
    }
  }
}
