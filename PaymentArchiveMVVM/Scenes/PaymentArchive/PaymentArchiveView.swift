//
//  PaymentArchiveView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 05.08.2025..
//

import SwiftUI

@MainActor @Observable
final class PaymentArchiveViewModel {
  private(set) var appState: AppState
  
  init(appState: AppState) {
    self.appState = appState
  }
  
  var colors: PaymentArchiveView.Colors {
    appState.colorPalette.paymentArchiveViewColors
  }
}

extension ColorPalette {
  var paymentArchiveViewColors: PaymentArchiveView.Colors {
    .init(
      background: background.primary,
      buttonTitle: text.buttonTitle
    )
  }
}

struct PaymentArchiveView: View {
  private var viewModel: PaymentArchiveViewModel
  
  @State
  private var isChangeThemeModalPresented: Bool = false
  
  init(
    viewModel: @autoclosure @escaping () -> PaymentArchiveViewModel
  ) {
    self.viewModel = viewModel()
  }

  var body: some View {
    Group {
      VStack(spacing: 12) {
        Button("New payment") {
          
        }
        .foregroundStyle(viewModel.colors.buttonTitle)
        Button("Change theme") {
          //viewModel.changeTheme()
          isChangeThemeModalPresented = true
        }
        .foregroundStyle(viewModel.colors.buttonTitle)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(viewModel.colors.background)
    .sheet(
      isPresented: $isChangeThemeModalPresented) {
        let viewModel = ChangeThemeViewModel(appState: self.viewModel.appState)
        ChangeThemeView(viewModel: viewModel)
      }
  }
}

extension PaymentArchiveView {
  struct Colors: Sendable, Equatable {
    let background: Color
    let buttonTitle: Color
  }
}

#Preview {
  @Previewable @State var appState: AppState = .init()
  PaymentArchiveView(viewModel: .init(appState: appState))
}
