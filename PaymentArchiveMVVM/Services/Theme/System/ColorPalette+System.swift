//
//  ColorPalette+System.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 06.08.2025..
//

import SwiftUI

extension ColorPalette {
  static let system: ColorPalette = ColorPalette(
    text: .init(
      primary: .primary,
      secondary: .secondary,
      link: .accentColor,
      caption: Color(.tertiaryLabel)
    ),
    highlight: .init(
      background: .blue,
      icon: .white,
      title: .white
    ),
    selector: .init(
      title: .blue,
      background: Color(.blue).opacity(0.1),
      border: .blue
    ),
    activityIndicator: .init(
      tint: .gray
    ),
    toggle: .init(
      tint: .blue
    )
  )
}
