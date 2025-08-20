//
//  PaymentArchiveMVVMApp.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

@Observable @MainActor
final class AppState {
  var selectedAccount: Account? = nil
  var payments: [Payment] = []
  var colorPalette: ColorPalette = .system
}

enum AppDependency {
  static let locale: Locale = .current
  static let persistenceController: PersistenceStore = SimplifiedDataStore.singleAccountWithMultiplePayments
}

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
          appState: AppState(),
          persistenceStore: SimplifiedDataStore.singleAccountWithMultiplePayments
        )
      )
      .environment(\.theme, Theme(rawValue: selectedThemeID) ?? Theme.defaultValue)
      .environment(\.setTheme) { newTheme in
        selectedThemeID = newTheme.rawValue
      }
    }
  }
}
