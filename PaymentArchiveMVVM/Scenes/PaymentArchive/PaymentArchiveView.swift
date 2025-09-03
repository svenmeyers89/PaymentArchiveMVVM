//
//  PaymentArchiveView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 05.08.2025..
//

import SwiftUI

struct PaymentArchiveView: View {
  enum ContentType {
    case loading
    case onboarding
    case listView([Payment])
    case error(String)
  }

  private enum Modal {
    case updateAccount(Account?)
    case updatePayment(Payment?)
    case changeTheme
  }
  
  private var viewModel: PaymentArchiveViewModel
  
  @Environment(\.sceneFactory) private var sceneFactory

  @State
  private var didLoadContentOnDidAppear: Bool = false
  @State
  private var presentedModal: Modal? = nil

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
            createAccountAction: {
              presentedModal = .updateAccount(nil)
            },
            showDemoAction: { print("Show Demo!") }
          )
        )
      case .listView(let payments):
        List(payments, id: \.id) { payment in
          Button(action: {
            presentedModal = .updatePayment(payment)
          }) {
            PaymentView(payment: payment)
              .frame(maxWidth: .infinity)
              .contentShape(Rectangle())
          }
          .buttonStyle(PlainButtonStyle())
        }
        .overlay {
          CircleButton(
            size: 70, iconName: "plus",
            colors: .init(background: .blue, icon: .white)
          ) {
            presentedModal = .updatePayment(nil)
          }
        }
      }
    }
    .onAppear {
      if !didLoadContentOnDidAppear {
        Task {
          await viewModel.loadContent()
          didLoadContentOnDidAppear = true
        }
      }
    }
    .sheet(
      isPresented: .init(
        get: { presentedModal != nil },
        set: { isPresented in
          if !isPresented {
            presentedModal = nil
          }
        }
      )
    ) {
      switch presentedModal {
      case .updateAccount(let account):
        sceneFactory?
          .buildEditAccountScene(account: account)
      case .updatePayment(let payment):
        sceneFactory?
          .buildEditPaymentScene(payment: payment)
      case .changeTheme, .none:
        EmptyView()
      }
    }
  }
}

#Preview {
  let sceneFactory = SceneFactory(
    paymentArchive: .init(
      persistanceStore: SimplifiedDataStore.empty
    )
  )
  return sceneFactory
    .buildPaymentArchiveScene()
    .environment(\.sceneFactory, sceneFactory)
}
