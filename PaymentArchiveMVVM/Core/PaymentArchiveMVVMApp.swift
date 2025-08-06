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
  
  var editPaymentState: EditPaymentState? {
    .init(
      colors: .init(
        background: colorPalette.background.primary,
        moneyAmountTextField: .init(
          background: colorPalette.background.header,
          title: colorPalette.text.primary,
          textField: colorPalette.text.secondary,
          currency: colorPalette.text.primary
        ),
        categorySelector: .init(
          categoryIcon: .init(
            iconBackground: colorPalette.highlight.icon,
            iconTint: colorPalette.highlight.tint
          ),
          categoryTitle: colorPalette.highlight.title,
          categoryBackground: colorPalette.selector.background,
          selectedCategoryBorder: colorPalette.selector.border,
          background: colorPalette.background.primary
        )
      ),
      edittedPayment: nil,
      selectedAccount: .init(name: "Perica", paymentIds: ["1", "2", "3"], currency: "$"),
      categories: Payment.Category.allCases
    )
  }
}

enum AppDependency {
  static let locale = Locale.current
}

@main
struct PaymentArchiveMVVMApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
