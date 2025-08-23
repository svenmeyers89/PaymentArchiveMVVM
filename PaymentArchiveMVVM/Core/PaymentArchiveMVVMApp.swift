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

  var body: some Scene {
    WindowGroup {
      PaymentArchiveView(
        viewModel: .init(
          paymentArchive: .init(
            persistanceStore: SimplifiedDataStore.empty
          )
        )
      )
      .environment(\.theme, Theme(rawValue: selectedThemeID) ?? Theme.defaultValue)
      .environment(\.setTheme) { newTheme in
        selectedThemeID = newTheme.rawValue
      }
    }
  }
}
