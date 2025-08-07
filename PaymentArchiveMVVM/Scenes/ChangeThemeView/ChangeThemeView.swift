//
//  ChangeThemeView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 06.08.2025..
//

import SwiftUI

@MainActor @Observable
final class ChangeThemeViewModel {
  private(set) var appState: AppState
  
  init(appState: AppState) {
    self.appState = appState
  }

  func changeTheme(_ theme: Theme) {
    switch theme {
    case .system:
      appState.colorPalette = ColorPalette.system
    case .custom:
      appState.colorPalette = ColorPalette.custom
    }
  }
}

enum Theme: String, Equatable, CaseIterable {
  case system
  case custom
}

struct ChangeThemeView: View {
  let viewModel: ChangeThemeViewModel
  
  var colors: ChangeThemeView.Colors {
    viewModel.appState.colorPalette.changeThemeViewColors
  }
  
  var body: some View {
    let colors = viewModel.appState.colorPalette.changeThemeViewColors
    
    ForEach(Theme.allCases, id: \.self) { theme in
      Button(
        action: {
          viewModel.changeTheme(theme)
        },
        label: {
          HStack {
            Text("\(theme)")
              .foregroundStyle(colors.title)
            Spacer()
            if viewModel.appState.colorPalette.selectedTheme == theme {
              Image(systemName: "checkmark.circle")
                .foregroundStyle(colors.icon)
            }
          }
          .padding(12)
          .background(colors.box)
          .cornerRadius(12)
        }
      )
      .buttonStyle(.plain)
      .padding(.horizontal, 12)
    }
    .background(colors.background)
  }
}

extension ChangeThemeView {
  struct Colors: Sendable {
    let background: Color
    let title: Color
    let icon: Color
    let box: Color
  }
}

#Preview {
  @Previewable @State var appState = AppState()
  ChangeThemeView(viewModel: .init(appState: appState))
}

extension ColorPalette {
  var changeThemeViewColors: ChangeThemeView.Colors {
    .init(
      background: background.primary,
      title: text.buttonTitle,
      icon: highlight.tint,
      box: background.header
    )
  }
}

fileprivate extension ColorPalette {
  var selectedTheme: Theme {
    self == ColorPalette.system ? .system : .custom
  }
}
