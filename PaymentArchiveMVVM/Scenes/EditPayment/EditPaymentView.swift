//
//  EditPaymentView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct EditPaymentView: View {
  @Bindable private var viewModel: EditPaymentViewModel
  
  @State private var isActionInProgress: Bool = false
  @State private var toastMessage: ToastBar.Message? = nil

  @Environment(\.theme) var theme

  init(viewModel: EditPaymentViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    ToastContainer(
      toastBarMessage: $toastMessage,
      duration: 3,
      content: {
        VStack {
          Spacer()
          
          MoneyAmountTextField(
            amount: $viewModel.amount,
            currency: viewModel.selectedAccount.currency,
            colors: moneyAmountTextFieldColors
          )
          .padding(.bottom, 16)
          
          CategorySelector(
            selectedCategory: $viewModel.category,
            categories: viewModel.categories,
            colors: categorySelectorColors
          )
          .padding(.bottom, 16)
          .fixedSize(horizontal: false, vertical: true)
          
          Button("Save") {
            Task {
              isActionInProgress = true
              let result = await viewModel.savePayment()
              switch result {
              case .success:
                print("success!")
              case .failure(let error):
                self.toastMessage = error.toastBarMessage
                print("error: \(error)")
              }
              isActionInProgress = false
            }
          }
          .padding(.bottom, 32)
          .disabled(isActionInProgress)
          
          Button("Cancel") {
            print("Canceled!")
          }
          
          Spacer()
        }
        .padding(.horizontal, 24)
        .background(backgroundColor)
      },
      completion: {
        self.toastMessage = nil
      }
    )
  }
}

extension EditPaymentView {
  struct Colors {
    let background: Color
    let moneyAmountTextField: MoneyAmountTextField.Colors
    let categorySelector: CategorySelector.Colors
    // TODO: Add button colors
  }

  var backgroundColor: Color {
    theme.background.primary
  }
  
  var moneyAmountTextFieldColors: MoneyAmountTextField.Colors {
    .init(
      background: theme.background.primary,
      title: theme.text.primary,
      textField: theme.text.secondary,
      currency: theme.text.primary
    )
  }
  
  var categorySelectorColors: CategorySelector.Colors {
    .init(
      categoryIcon: .init(
        iconBackground: theme.highlight.icon,
        iconTint: theme.highlight.tint
      ),
      categoryTitle: theme.selector.title,
      categoryBackground: theme.selector.background,
      selectedCategoryBorder: theme.selector.border,
      background: theme.background.primary
    )
  }
}

#Preview {
  EditPaymentView(
    viewModel: EditPaymentViewModel(
      edittedPayment: nil,
      selectedAccount: Account(
        name: "Perica",
        paymentIds: ["1", "2", "3"],
        currency: "$",
        useBiometry: false
      ),
      categories: Payment.Category.allCases,
      dataManager: MockedDataStore()
    )
  )
  .environment(\.theme, .system)
}

fileprivate struct MockedDataStore: EditPaymentDataManager {
  func save(payment: Payment) async throws {
    print("Saving...")
    try await Task.sleep(nanoseconds: 3_000_000_000)
    print("Saved!")
  }
}
