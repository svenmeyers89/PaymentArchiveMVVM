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
  @Environment(\.theme) private var theme

  @State
  private var didLoadContentOnDidAppear: Bool = false
  @State
  private var presentedModal: Modal? = nil

  init(viewModel: PaymentArchiveViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    NavigationStack {
      Group {
        switch viewModel.contentType {
        case .loading:
          ProgressView()
        case .error(let message):
          EmptyArchiveView(
            colors: emptyArchiveViewColors,
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
            colors: emptyArchiveViewColors,
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
              PaymentView(
                payment: payment,
                colors: paymentViewColors
              )
              .frame(maxWidth: .infinity)
              .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
          }
          .overlay {
            CircleButton(
              size: 70, iconName: "plus",
              colors: circleButtonColors
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
        case .changeTheme:
          ChangeThemeView()
        default:
          EmptyView()
            .onAppear {
              assertionFailure("Unsupported modal!")
            }
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            presentedModal = .changeTheme
          } label: {
            Image(systemName: "paintpalette")
          }
        }
      }
    }
  }
}

extension PaymentArchiveView {
  var paymentViewColors: PaymentView.Colors {
    .init(
      background: .yellow, // theme.colorPalette.background.primary,
      categoryIcon: .init(
        iconBackground: theme.colorPalette.highlight.icon,
        iconTint: theme.colorPalette.highlight.tint
      ),
      paymentDateTime: theme.colorPalette.text.secondary,
      categoryName: theme.colorPalette.text.primary,
      paymentAmount: theme.colorPalette.text.primary
    )
  }

  var emptyArchiveViewColors: EmptyArchiveView.Colors {
    .init(
      background: theme.colorPalette.background.primary,
      icon: theme.colorPalette.highlight.tint,
      title: theme.colorPalette.text.primary,
      description: theme.colorPalette.text.primary,
      button: theme.colorPalette.text.link
    )
  }
  
  var circleButtonColors: CircleButton.Colors {
    .init(
      background: theme.colorPalette.highlight.tint,
      icon: theme.colorPalette.highlight.icon
    )
  }
}

#Preview {
  @Previewable @State var selectedThemeID: String = Theme.defaultValue.rawValue
  let sceneFactory = SceneFactory(
    paymentArchive: .init(
      persistanceStore: SimplifiedDataStore.singleAccountWithMultiplePayments
    )
  )
  return sceneFactory
    .buildPaymentArchiveScene()
    .environment(\.sceneFactory, sceneFactory)
    .environment(\.theme, Theme(rawValue: selectedThemeID) ?? Theme.defaultValue)
    .environment(\.setTheme) { newTheme in
      selectedThemeID = newTheme.rawValue
    }
}
