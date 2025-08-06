//
//  ColorPalette+Custom.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 06.08.2025..
//

import SwiftUI

extension ColorPalette {
  static let custom: ColorPalette = .init(
    background: .init(
      primary: Color("BackgroundPrimary"),
      header: Color("BackgroundHeader"),
      box: Color("BackgroundBox")
    ),
    text: .init(
      primary: Color("TextPrimary"),
      secondary: Color("TextSecondary"),
      buttonTitle: Color("TextButtonTitle"),
      caption: Color("TextCaption")
    ),
    highlight: .init(
      tint: Color("HighlightTint"),
      icon: Color("HighlightIcon"),
      title: Color("HighlightTitle")
    ),
    selector: .init(
      title: Color("SelectorTitle"),
      background: Color("SelectorBackground"),
      border: Color("SelectorBorder")
    ),
    activityIndicator: .init(
      tint: Color("ActivityIndicatorTint")
    )
  )
}
