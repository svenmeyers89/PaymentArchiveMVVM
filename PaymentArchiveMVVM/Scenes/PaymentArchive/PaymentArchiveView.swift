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
  
  private(set) var contentType: ContentType?
  
  private let paymentArchive: PaymentArchive

  init(paymentArchive: PaymentArchive) {
    self.paymentArchive = paymentArchive
  }

  func loadContent() async {
    do {
      contentType = .loading
      try await paymentArchive.loadInitialState()

      if let selectedAccountId = paymentArchive.state.selectedAccountId {
        let accountPayments = paymentArchive.state.payments[selectedAccountId] ?? []
        contentType = .listView(accountPayments)
      } else {
        contentType =  .onboarding
      }
    } catch {
      let error = (error as NSError).localizedDescription
      contentType = .error(message: error)
    }
  }
}

//extension ColorPalette {
//  var paymentArchiveViewColors: PaymentArchiveView.Colors {
//    .init(
//      background: background.primary,
//      buttonTitle: text.link
//    )
//  }
//}

struct PaymentArchiveView: View {
  private var viewModel: PaymentArchiveViewModel
  
  @State
  private var isChangeThemeModalPresented: Bool = false
  
  init(viewModel: PaymentArchiveViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    Group {
      switch viewModel.contentType {
      case .loading:
        ProgressView()
      case .error(let message):
        EmptyArchiveView(
          configuration: .error(
            message: message,
            refreshAction: {
              Task {
                await viewModel.loadContent()
              }
            }
          )
        )
      case .onboarding:
        EmptyArchiveView(
          configuration: .onboarding(
            createAccountAction: { print("Create account!") },
            showDemoAction: { print("Show Demo!") }
          )
        )
      case .listView(let payments):
        List(payments, id: \.id) { payment in
          PaymentView(payment: payment)
        }
      case .none:
        Text("Bla")
        // EmptyView()
      }
    }
    .onAppear {
      if viewModel.contentType == nil {
        Task {
          await viewModel.loadContent()
        }
      }
    }
  }
}

//extension PaymentArchiveView {
//  struct Colors: Sendable, Equatable {
//    let background: Color
//    let buttonTitle: Color
//  }
//}

#Preview {
  @Previewable @State var paymentArchive = PaymentArchive(
    persistanceStore: SimplifiedDataStore.empty
  )
  return PaymentArchiveView(
    viewModel: .init(paymentArchive: paymentArchive)
  )
}
