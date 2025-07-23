//
//  EditPaymentView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct EditPaymentView: View {
  private let state: EditPaymentState
  /*@StateObject*/ private var viewModel: EditPaymentViewModel
  
  @State private var amount: String
  @State private var category: Payment.Category?
  @State private var note: String?

  init(
    state: EditPaymentState,
    viewModel: @autoclosure @escaping () -> EditPaymentViewModel
  ) {
    //_viewModel = StateObject(wrappedValue: viewModel())
    self.state = state

    let amount: String = {
      guard let amount = state.edittedPayment?.amount else {
        return ""
      }
      return String(format: "%.2f", amount)
    }()
    self.amount = amount
    self.category = state.edittedPayment?.category
    self.note = state.edittedPayment?.note

    self.viewModel = viewModel()
  }

  var body: some View {
    VStack {
      Spacer()
      
      MoneyAmountTextField(
        amount: $amount,
        currency: state.currency,
        colors: state.colors.moneyAmountTextField
      )
      .padding(.bottom, 16)
      
      CategorySelector(
        selectedCategory: $category,
        categories: state.categories,
        colors: state.colors.categorySelector
      )
      .padding(.bottom, 16)
      .fixedSize(horizontal: false, vertical: true)
      
      Button("Save") {
        print(
          "Saved: amount: \(self.amount), category: \(self.category?.rawValue ?? "no category")"
        )
      }
      .padding(.bottom, 32)

      Button("Cancel") {
        print("Canceled!")
      }
      
      Spacer()
    }
    .padding(.horizontal, 24)
    .background(state.colors.background)
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
    state: .init(
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
      currency: "$",
      categories: Payment.Category.allCases
    ),
    viewModel: EditPaymentViewModel(dataManager: MockedDataStore())
  )
}

fileprivate struct MockedDataStore: EditPaymentDataManager {
  func save(payment: Payment) async throws {
    print("Saving...")
    try await Task.sleep(nanoseconds: 1_000_000)
    print("Saved!")
  }
}
