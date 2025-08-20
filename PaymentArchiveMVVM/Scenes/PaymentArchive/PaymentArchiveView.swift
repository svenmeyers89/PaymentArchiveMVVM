//
//  PaymentArchiveView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 05.08.2025..
//

import SwiftUI

@MainActor @Observable
final class PaymentArchiveViewModel {
  enum ContentType {
    case loading
    case onboarding
    case listView([Payment])
    case error(message: String)
  }
  
  private(set) var appState: AppState
  private(set) var contentType: ContentType?

  private let persistenceStore: PersistenceStore
  
  init(
    appState: AppState,
    persistenceStore: PersistenceStore
  ) {
    self.appState = appState
    self.persistenceStore = persistenceStore
  }
  
  var colors: PaymentArchiveView.Colors {
    appState.colorPalette.paymentArchiveViewColors
  }
  
  func loadContent() async {
    do {
      self.contentType = .loading
      guard let account = try await persistenceStore.loadAllAccounts().first else {
        self.contentType = .onboarding
        return
      }
      let payments = try await persistenceStore.loadPayments(accountId: account.id)
      self.contentType = .listView(payments)
    } catch {
      let error = (error as NSError).localizedDescription
      self.contentType = .error(message: error)
    }
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
      isPresented: $isChangeThemeModalPresented
    ) {
      let viewModel = ChangeThemeViewModel(appState: self.viewModel.appState)
      ChangeThemeView(viewModel: viewModel)
    }
    .onAppear {
      Task {
        await viewModel.loadContent()
      }
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
  PaymentArchiveView(
    viewModel: .init(
      appState: appState,
      persistenceStore: SimplifiedDataStore.empty
    )
  )
}
