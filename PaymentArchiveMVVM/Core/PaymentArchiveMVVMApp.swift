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
}

@main
struct PaymentArchiveMVVMApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
