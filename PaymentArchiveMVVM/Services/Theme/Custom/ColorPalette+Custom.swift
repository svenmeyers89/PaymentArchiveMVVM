//
//  ColorPalette+Custom.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 06.08.2025..
//

import SwiftUI

extension ColorPalette {
  static let custom: ColorPalette = .init(
    text: .init(
      primary: Color("TextPrimary"),
      secondary: Color("TextSecondary"),
      link: Color("TextButtonTitle"),
      caption: Color("TextCaption")
    ),
    highlight: .init(
      background: Color("HighlightBackground"),
      icon: Color("HighlightIcon"),
      title: Color("HighlightTitle")
    ),
    selector: .init(
      title: Color("SelectorTitle"),
      background: Color("SelectorBackground"),
      border: Color("SelectorBorder"),
      icon: Color("SelectorIcon")
    ),
    activityIndicator: .init(
      tint: Color("ActivityIndicatorTint")
    ),
    toggle: .init(
      tint: Color("ToggleTint")
    ),
    toastBar: .init(
      background: Color("ToastBarBackground"),
      icon: Color("ToastBarIcon"),
      text: Color("ToastBarText")
    )
  )
}
