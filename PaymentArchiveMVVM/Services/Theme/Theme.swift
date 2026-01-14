//
//  Theme.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.08.2025..
//

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
