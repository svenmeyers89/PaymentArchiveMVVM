//
//  Theme+Environment.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 14.01.2026..
//

import SwiftUI

private typealias ThemeIDKey = Theme

@MainActor
extension Theme: @preconcurrency EnvironmentKey {
  static let defaultValue: Self = .system
}

@MainActor
extension EnvironmentValues {
  var theme: Theme {
    get { self[ThemeIDKey.self] }
    set { self[ThemeIDKey.self] = newValue }
  }
  
  var setTheme: (Theme) -> Void {
    get { self[SetThemeIDKey.self] }
    set { self[SetThemeIDKey.self] = newValue }
  }
}

@MainActor
private struct SetThemeIDKey: @preconcurrency EnvironmentKey {
  static let defaultValue: (Theme) -> Void = { _ in }
}
