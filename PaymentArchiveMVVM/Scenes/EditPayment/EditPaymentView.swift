//
//  EditPaymentView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct EditPaymentView: View {
  private var viewModel: EditPaymentViewModel
  
  @State private var amount: Float?
  @State private var category: Payment.Category?
  @State private var note: String?
  
  @State private var isActionInProgress: Bool = false
  @State private var toastMessage: ToastBar.Message? = nil

  init(
    viewModel: @autoclosure @escaping () -> EditPaymentViewModel
  ) {
    self.viewModel = viewModel()
    self.amount = viewModel().state.edittedPayment?.amount
    self.category = viewModel().state.edittedPayment?.category
    self.note = viewModel().state.edittedPayment?.note
  }

  var body: some View {
    ToastContainer(
      toastBarMessage: $toastMessage,
      duration: 3,
      content: {
        VStack {
          Spacer()
          
          MoneyAmountTextField(
            amount: $amount,
            locale: AppDependency.locale,
            currency: viewModel.state.selectedAccount.currency,
            colors: viewModel.state.colors.moneyAmountTextField
          )
          .padding(.bottom, 16)
          
          CategorySelector(
            selectedCategory: $category,
            categories: viewModel.state.categories,
            colors: viewModel.state.colors.categorySelector
          )
          .padding(.bottom, 16)
          .fixedSize(horizontal: false, vertical: true)
          
          Button("Save") {
            Task {
              isActionInProgress = true
              let result = await viewModel
                .savePayment(
                  amount: amount,
                  category: category,
                  note: note
                )
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
        .background(viewModel.state.colors.background)
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
}

#Preview {
  EditPaymentView(
    viewModel: EditPaymentViewModel(
      initialState: .init(
        colors: .init(
          background: .yellow,
          moneyAmountTextField: .init(
            background: .green,
            title: .black,
            textField: .orange,
            currency: .black
          ),
          categorySelector: .init(
            categoryIcon: .init(
              iconBackground: .green,
              iconTint: .white
            ),
            categoryTitle: .purple,
            categoryBackground: .gray,
            selectedCategoryBorder: .blue,
            background: .brown
          )
        ),
        edittedPayment: nil,
        selectedAccount: Account(
          name: "Perica",
          paymentIds: ["1", "2", "3"],
          currency: "$",
          useBiometry: false
        ),
        categories: Payment.Category.allCases
      ),
      dataManager: MockedDataStore()
    )
  )
}

fileprivate struct MockedDataStore: EditPaymentDataManager {
  func save(payment: Payment) async throws {
    print("Saving...")
    try await Task.sleep(nanoseconds: 3_000_000_000)
    print("Saved!")
  }
}
