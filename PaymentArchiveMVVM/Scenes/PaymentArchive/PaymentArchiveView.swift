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
    case listView(
      sections: [PaymentGroup],
      currency: Currency,
      selectedAccountId: String
    )
    case error(String)
  }

  private enum Modal {
    case updateAccount(EditAccountUseCase)
    case updatePayment(EditPaymentUseCase)
    case changeTheme
    case filterPaymentCategories
  }

  @State
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
                presentedModal = .updateAccount(.addNewAccount)
              },
              showDemoAction: { print("Show Demo!") }
            )
          )
        case let .listView(
          paymentGroups,
          currency,
          selectedAccountId
        ):
          List(paymentGroups, id: \.id) { paymentGroup in
            switch paymentGroup.kind {
            case .monthlyStats:
              Section {
                PeriodicalExpenseView(paymentGroup: paymentGroup)
              }
              
            case .dailyPayments:
              Section {
                PeriodicalExpenseView(paymentGroup: paymentGroup)
                ForEach(paymentGroup.payments, id: \.id) { payment in
                  Button(action: {
                    presentedModal = .updatePayment(.editPayment(payment))
                  }) {
                    PaymentView(
                      payment: payment,
                      currency: currency,
                      colors: paymentViewColors
                    )
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                  }
                  .buttonStyle(PlainButtonStyle())
                }
              }
            }
          }
          .overlay {
            CircleButton(
              size: 70, iconName: "plus",
              colors: circleButtonColors
            ) {
              presentedModal = .updatePayment(
                .addNewPayment(selectedAccountId: selectedAccountId)
              )
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
        case .updateAccount(let useCase):
          sceneFactory?
            .buildEditAccountScene(useCase: useCase)
        case .updatePayment(let useCase):
          sceneFactory?
            .buildEditPaymentScene(useCase: useCase)
        case .changeTheme:
          ChangeThemeView()
        case .filterPaymentCategories:
          NavigationStack {
            CategoryListView(
              allPaymentCategories: viewModel.allPaymentCategories,
              selectedPaymentCategories: viewModel.selectedPaymentCategories,
              colors: categoryListViewColors) { selectedPaymentCategories in
                viewModel.didConfirmSelection(
                  paymentCategories: selectedPaymentCategories
                )
              }
          }
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
        
        ToolbarItem(placement: .topBarLeading) {
          Button {
            presentedModal = .filterPaymentCategories
          } label: {
            Image(systemName: "line.3.horizontal.decrease")
          }
        }
      }
    }
  }
}

extension PaymentArchiveView {
  private var categoryIconColors: CategoryIcon.Colors {
    .init(
      iconBackground: theme.highlight.icon,
      iconTint: theme.highlight.tint
    )
  }
  
  var paymentViewColors: PaymentView.Colors {
    .init(
      background: theme.background.primary,
      categoryIcon: categoryIconColors,
      paymentDateTime: theme.text.secondary,
      categoryName: theme.text.primary,
      paymentAmount: theme.text.primary
    )
  }

  var emptyArchiveViewColors: EmptyArchiveView.Colors {
    .init(
      background: theme.background.primary,
      icon: theme.highlight.tint,
      title: theme.text.primary,
      description: theme.text.primary,
      button: theme.text.link
    )
  }
  
  var circleButtonColors: CircleButton.Colors {
    .init(
      background: theme.highlight.tint,
      icon: theme.highlight.icon
    )
  }
  
  var categoryListViewColors: CategoryListView.Colors {
    .init(
      categoryIcon: categoryIconColors,
      categoryListItem: .init(
        title: theme.text.primary,
        background: theme.background.primary,
        toggle: theme.toggle.tint
      ),
      background: theme.background.primary
    )
  }
}

#Preview {
  @Previewable @State var selectedThemeID: String = Theme.defaultValue.rawValue
  let dependencyManager = DependencyManager.mockedWithPopulatedStore
  return dependencyManager
    .sceneFactory
    .buildPaymentArchiveScene()
    .environment(\.sceneFactory, dependencyManager.sceneFactory)
    .environment(\.theme, Theme(rawValue: selectedThemeID) ?? Theme.defaultValue)
    .environment(\.setTheme) { newTheme in
      selectedThemeID = newTheme.rawValue
    }
}
