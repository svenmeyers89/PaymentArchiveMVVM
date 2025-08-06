//
//  PaymentArchiveView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 05.08.2025..
//

import SwiftUI

@MainActor @Observable
final class PaymentArchiveState {
  var colorPalette: ColorPalette

  init(colorPalette: ColorPalette) {
    self.colorPalette = colorPalette
  }

  fileprivate var colors: PaymentArchiveView.Colors {
    .init(
      background: colorPalette.background.primary,
      buttonTitle: colorPalette.text.buttonTitle
    )
  }
}

struct PaymentArchiveView: View {
  let state: PaymentArchiveState
  
  var body: some View {
    Group {
      VStack(spacing: 12) {
        Button("New payment") {
          
        }
        .foregroundStyle(state.colors.buttonTitle)
        Button("Change theme") {
          if state.colorPalette == .system {
            state.colorPalette = .custom
          } else {
            state.colorPalette = .system
          }
        }
        .foregroundStyle(state.colors.buttonTitle)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(state.colors.background)
  }
}

extension PaymentArchiveView {
  struct Colors: Sendable, Equatable {
    let background: Color
    let buttonTitle: Color
  }
}

#Preview {
  PaymentArchiveView(state: PaymentArchiveState(colorPalette: .system))
}
