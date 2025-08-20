//
//  ColorPalette+Environment.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.08.2025..
//

import SwiftUI

@MainActor
@dynamicMemberLookup
enum Theme: String, CaseIterable {
  case system
  case custom
  
  var colorPalette: ColorPalette {
    switch self {
    case .system:
      return ColorPalette.system
    case .custom:
      return ColorPalette.custom
    }
  }
  
  subscript<T>(dynamicMember keyPath: KeyPath<ColorPalette, T>) -> T {
    colorPalette[keyPath: keyPath]
  }
}

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

private typealias ThemeIDKey = Theme

@MainActor
private struct SetThemeIDKey: @preconcurrency EnvironmentKey {
  static let defaultValue: (Theme) -> Void = { _ in }
}
