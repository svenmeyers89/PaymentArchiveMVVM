//
//  EditAccountView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 09.08.2025..
//

import SwiftUI

struct EditAccountView: View {
  @State private var viewModel: EditAccountViewModel

  @State private var isActionInProgress: Bool = false
  @State private var toastMessage: ToastBar.Message? = nil
  
  @Environment(\.theme) private var theme
  @Environment(\.dismiss) private var dismiss
  
  init(viewModel: EditAccountViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    NavigationStack {
      ToastContainer(
        toastBarMessage: $toastMessage) {
          VStack(spacing: 8) {
            TextField("Account name", text: $viewModel.accountName)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .foregroundStyle(textFieldTextColor)
            
            Toggle(isOn: $viewModel.useBiometry) {
              Text("Use biometry on app open?")
                .font(.body)
            }
            .foregroundStyle(biometryTitleColor)
            .tint(biometricToggleSwitchColor)
            .padding(.bottom, 24)
            .padding(.horizontal, 8)
            
            VStack(spacing: 12) {
              TextField("Currency", text: $viewModel.currencyCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundStyle(textFieldTextColor)
                .disabled(viewModel.isEditingCurrencyDisabled)

              if !viewModel.isEditingCurrencyDisabled {
                CurrencySelector(
                  currencies: Currency.predefined,
                  colors: currencySelectorColors
                ) { selectedCurrency in
                  viewModel.currencyCode = selectedCurrency.code
                }
              }
            }
            
            Spacer()
          }
          .padding()
          .background(backgroundColor)
        } completion: {
          self.toastMessage = nil
        }
        .toolbar {
          ToolbarItem(placement: .principal) {
            Text(viewModel.isEdittingExistingAccount ? "Edit Account" : "New Account")
          }
          
          ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
              dismiss()
            }
          }
          
          ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
              self.isActionInProgress = true
              
              Task {
                let result = await viewModel.save()

                switch result {
                case .success:
                  dismiss()
                case .failure(let error):
                  self.toastMessage = ToastBar.Message(
                    text: error.message,
                    type: .error
                  )
                }
                
                self.isActionInProgress = false
              }
            }
          }
        }
    }
    .disabled(isActionInProgress)
  }
}

extension EditAccountView {
  var backgroundColor: Color {
    theme.background.primary
  }
  
  var textFieldTextColor: Color {
    theme.text.primary
  }
  
  var biometryTitleColor: Color {
    theme.text.primary
  }
  
  var biometricToggleSwitchColor: Color {
    theme.highlight.tint
  }
  
  var currencySelectorColors: CurrencySelector.Colors {
    .init(
      background: theme.background.primary,
      buttonBackground: theme.selector.background,
      buttonText: theme.selector.title
    )
  }
}

#Preview {
  let useCase: EditAccountUseCase =
    //.addNewAccount
    .editAccount(.init(name: "Sven", currency: Currency.eur, useBiometry: true))
  EditAccountView(
    viewModel: .init(
      useCase: useCase,
      dataManager: MockedDataStore()
    )
  )
}

fileprivate struct MockedDataStore: EditAccountDataManager {
  func save(account: Account) async throws {
    print("Saving...")
    try await Task.sleep(nanoseconds: 3_000_000_000)
    print("Saved!")
  }
}
