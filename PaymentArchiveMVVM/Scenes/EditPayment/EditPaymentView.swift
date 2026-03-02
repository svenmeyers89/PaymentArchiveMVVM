//
//  EditPaymentView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct EditPaymentView: View {
  @State private var viewModel: EditPaymentViewModel
  
  @State private var isActionInProgress: Bool = false
  @State private var toastMessage: ToastBar.Message? = nil

  @Environment(\.theme) private var theme
  @Environment(\.dismiss) private var dismiss

  init(viewModel: EditPaymentViewModel) {
    _viewModel = .init(initialValue: viewModel)
  }

  var body: some View {
    ToastContainer(
      toastBarMessage: $toastMessage,
      duration: 3,
      content: {
        VStack {
          Spacer()
          
          MoneyAmountTextField(
            amountMinorUnits: $viewModel.amountMinorUnits,
            currency: viewModel.currency,
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
              
              isActionInProgress = false

              switch result {
              case .success:
                print("success!")
                dismiss()
              case .failure(let error):
                self.toastMessage = error.toastBarMessage
                print("error: \(error)")
              }
            }
          }
          .padding(.bottom, 32)
          .disabled(isActionInProgress)
          
          Button("Cancel") {
            dismiss()
          }
          
          Spacer()
        }
        .padding(.horizontal, 24)
      },
      completion: {
        self.toastMessage = nil
      }
    )
  }
}

extension EditPaymentView {
  var moneyAmountTextFieldColors: MoneyAmountTextField.Colors {
    .init(
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
      selectedCategoryBorder: theme.selector.border
    )
  }
}

#Preview {
  let useCase: EditPaymentUseCase =
    .editPayment(.init(accountId: "123", amountMinorUnits: 123, category: .accommodation))
    //.addNewPayment(selectedAccountId: "123")
  EditPaymentView(
    viewModel: EditPaymentViewModel(
      useCase: useCase,
      currency: Currency.usd,
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
