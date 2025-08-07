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

@main
struct PaymentArchiveMVVMApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
