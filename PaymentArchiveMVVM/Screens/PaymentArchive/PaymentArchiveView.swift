//
//  PaymentArchiveView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 05.08.2025..
//

import SwiftUI

struct PaymentArchiveView: View {
  @State
  private var viewModel: PaymentArchiveViewModel
  
  @Environment(\.screenFactory) private var screenFactory
  @Environment(\.theme) private var theme

  @State
  private var didLoadContentOnDidAppear: Bool = false
  @State
  private var presentedModal: Modal? = nil

  init(viewModel: PaymentArchiveViewModel) {
    _viewModel = .init(initialValue: viewModel)
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
              showDemoAction: {
                Task {
                  await viewModel.enterDemoMode()
                }
              }
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
          .overlay(alignment: .bottomTrailing) {
            CircleButton(
              size: 70, iconName: "plus",
              colors: circleButtonColors
            ) {
              presentedModal = .updatePayment(
                .addNewPayment(selectedAccountId: selectedAccountId)
              )
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
          }
          .overlay(alignment: .bottomLeading) {
            if viewModel.isInDemoMode {
              ExitDemoButton(
                title: "Exit Demo",
                colors: exitDemoButtonColors
              ) {
                Task {
                  await viewModel.exitDemoMode()
                }
              }
              .padding(.leading, 20)
              .padding(.bottom, 20)
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
          screenFactory?
            .buildEditAccountScreen(useCase: useCase)
        case .updatePayment(let useCase):
          screenFactory?
            .buildEditPaymentScreen(useCase: useCase)
        case .changeTheme:
          ChangeThemeView(colors: changeThemeViewColors)
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
      iconBackground: theme.selector.background,
      iconTint: theme.highlight.background
    )
  }
  
  var paymentViewColors: PaymentView.Colors {
    .init(
      categoryIcon: categoryIconColors,
      paymentDateTime: theme.text.secondary,
      categoryName: theme.text.primary,
      paymentAmount: theme.text.primary
    )
  }

  var emptyArchiveViewColors: EmptyArchiveView.Colors {
    .init(
      icon: theme.highlight.background,
      title: theme.text.primary,
      description: theme.text.primary,
      button: theme.text.link
    )
  }
  
  var circleButtonColors: CircleButton.Colors {
    .init(
      background: theme.highlight.background,
      icon: theme.highlight.icon
    )
  }
  
  var categoryListViewColors: CategoryListView.Colors {
    .init(
      categoryIcon: categoryIconColors,
      categoryListItem: .init(
        title: theme.text.primary,
        toggle: theme.toggle.tint
      )
    )
  }

  var changeThemeViewColors: ChangeThemeView.Colors {
    .init(
      themeTitle: theme.selector.title,
      checkmarkIcon: theme.selector.icon,
      themeBox: theme.selector.background
    )
  }

  var exitDemoButtonColors: ExitDemoButton.Colors {
    .init(
      background: .gray.opacity(0.2),
      text: .primary
    )
  }
}

#Preview {
  @Previewable @State var selectedThemeID: String = Theme.defaultValue.rawValue
  let dependencyManager = DependencyManager.mockedWithPopulatedStore
  return dependencyManager
    .screenFactory
    .buildPaymentArchiveScreen()
    .environment(\.screenFactory, dependencyManager.screenFactory)
    .environment(\.theme, Theme(rawValue: selectedThemeID) ?? Theme.defaultValue)
    .environment(\.setTheme) { newTheme in
      selectedThemeID = newTheme.rawValue
    }
}

