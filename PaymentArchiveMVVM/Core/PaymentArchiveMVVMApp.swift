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
  
  let dependencyManager: DependencyManager = .live

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
