//
//  ChangeThemeView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 06.08.2025..
//

import SwiftUI

struct ChangeThemeView: View {
  @Environment(\.theme) private var selectedTheme
  @Environment(\.setTheme) private var setTheme

  var body: some View {
    ForEach(Theme.allCases, id: \.self) { theme in
      Button(
        action: {
          setTheme(theme)
        },
        label: {
          HStack {
            Text("\(theme)")
              .foregroundStyle(themeTitleColor)
            Spacer()
            if selectedTheme == theme {
              Image(systemName: "checkmark.circle")
                .foregroundStyle(checkmarkIconColor)
            }
          }
          .padding(12)
          .background(themeBoxColor)
          .cornerRadius(12)
        }
      )
      .buttonStyle(.plain)
      .padding(.horizontal, 12)
    }
  }
}

extension ChangeThemeView {
  var themeTitleColor: Color {
    selectedTheme.colorPalette.text.primary
  }
  
  var checkmarkIconColor: Color {
    selectedTheme.colorPalette.highlight.tint
  }
  
  var themeBoxColor: Color {
    selectedTheme.colorPalette.selector.background
  }
}

#Preview {
  @Previewable @State var selectedThemeID: String = Theme.defaultValue.rawValue
  ChangeThemeView()
    .environment(\.theme, Theme(rawValue: selectedThemeID) ?? Theme.defaultValue)
    .environment(\.setTheme) { newTheme in
      selectedThemeID = newTheme.rawValue
    }
}
