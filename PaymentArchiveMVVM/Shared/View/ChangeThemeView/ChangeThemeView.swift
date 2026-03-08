//
//  ChangeThemeView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 06.08.2025..
//

import SwiftUI

struct ChangeThemeView: View {
  let colors: Colors

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
            Text(theme.name)
              .foregroundStyle(colors.themeTitle)
            Spacer()
            if selectedTheme == theme {
              Image(systemName: "checkmark.circle")
                .foregroundStyle(colors.checkmarkIcon)
            }
          }
          .padding(12)
          .background(colors.themeBox)
          .cornerRadius(12)
        }
      )
      .buttonStyle(.plain)
      .padding(.horizontal, 12)
    }
  }
}

extension Theme {
  fileprivate var name: String {
    rawValue
  }
}

#Preview {
  @Previewable @State var selectedThemeID: String = Theme.defaultValue.rawValue
  ChangeThemeView(
    colors: .init(
      themeTitle: .primary,
      checkmarkIcon: .blue,
      themeBox: .gray.opacity(0.2)
    )
  )
  .environment(\.theme, Theme(rawValue: selectedThemeID) ?? Theme.defaultValue)
  .environment(\.setTheme) { newTheme in
    selectedThemeID = newTheme.rawValue
  }
}
