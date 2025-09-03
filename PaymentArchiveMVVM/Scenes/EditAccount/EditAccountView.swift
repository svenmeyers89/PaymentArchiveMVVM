//
//  EditAccountView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 09.08.2025..
//

import SwiftUI

struct EditAccountView: View {
  @Bindable private var viewModel: EditAccountViewModel

  @State private var isActionInProgress: Bool = false
  @State private var toastMessage: ToastBar.Message? = nil
  
  @Environment(\.dismiss) var dismiss
  
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
            
            Toggle(isOn: $viewModel.useBiometry) {
              Text("Use biometry on app open?")
                .font(.body)
            }
            .padding(.bottom, 24)
            .padding(.horizontal, 8)
            
            VStack(spacing: 12) {
              TextField("Currency", text: $viewModel.currency)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(viewModel.isEditingCurrencyDisabled)

              if !viewModel.isEditingCurrencyDisabled {
                HStack(spacing: 16) {
                  ForEach(PrederfinedCurrency.allCases, id: \.self) { currency in
                    Button(action: {
                      viewModel.currency = currency.rawValue
                    }) {
                      HStack {
                        Spacer()
                        Text(currency.symbol)
                          .font(.headline)
                          .foregroundStyle(.green)
                          .padding(.vertical, 8)
                        Spacer()
                      }
                      .background(.yellow)
                      .cornerRadius(10)
                    }
                  }
                }
              }
            }
            
            Spacer()
          }
          .padding()
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
                  break
                case .failure(let error):
                  self.toastMessage = ToastBar.Message(
                    text: error.message,
                    type: .error
                  )
                }
                
                self.isActionInProgress = false
                dismiss()
              }
            }
          }
        }
    }
    .disabled(isActionInProgress)
  }
}

#Preview {
  EditAccountView(
    viewModel: .init(
      edittedAccount: nil, //.init(name: "Sven", paymentIds: [], currency: "EUR", useBiometry: true),
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
