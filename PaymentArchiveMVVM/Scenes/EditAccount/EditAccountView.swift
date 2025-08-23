//
//  EditAccountView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 09.08.2025..
//

import SwiftUI

protocol EditAccountDataManager: Sendable {
  func save(account: Account) async throws
}

enum EditAccountError: Error {
  case accountNameEmpty
  case currencyEmpty
  case currencyNotValid
  case saveAccountFailed(Error)
  
  var message: String {
    switch self {
    case .accountNameEmpty:
      return "Account name cannot be empty"
    case .currencyEmpty:
      return "Currency cannot be empty"
    case .currencyNotValid:
      return "Currency must be exactly 3 characters long"
    case .saveAccountFailed(let error):
      return "Saving account failed: \(error)"
    }
  }
}

@MainActor @Observable
final class EditAccountViewModel {
  let edittedAccount: Account?
  private let dataManager: EditAccountDataManager

  init(
    edittedAccount: Account?,
    dataManager: EditAccountDataManager
  ) {
    self.edittedAccount = edittedAccount
    self.dataManager = dataManager
  }
  
  var isEditingCurrencyDisabled: Bool {
    edittedAccount != nil
  }
  
  func save(
    accountName: String,
    currency: String,
    useBiometry: Bool
  ) async -> Result<Void, EditAccountError> {
    guard !accountName.isEmpty else {
      return .failure(EditAccountError.accountNameEmpty)
    }
    guard !currency.isEmpty else {
      return .failure(EditAccountError.currencyEmpty)
    }
    guard currency.count == 3 else {
      return .failure(EditAccountError.currencyNotValid)
    }

    do {
      let account = Account(
        name: accountName,
        paymentIds: [],
        currency: currency.uppercased(),
        useBiometry: useBiometry
      )
      try await dataManager.save(account: account)
      return .success(())
    } catch {
      return .failure(.saveAccountFailed(error))
    }
  }
}

enum PrederfinedCurrency: String, CaseIterable {
  case eur
  case usd
  case yen
  case gbp
  
  var symbol: String {
    switch self {
    case .eur:
      return "€"
    case .usd:
      return "$"
    case .yen:
      return "¥"
    case .gbp:
      return "£"
    }
  }
}

struct EditAccountView: View {
  private let viewModel: EditAccountViewModel
  
  @State private var accountName: String
  @State private var currency: String
  @State private var useBiometry: Bool

  @State private var isActionInProgress: Bool = false
  @State private var toastMessage: ToastBar.Message? = nil
  
  @Environment(\.dismiss) var dismiss
  
  init(viewModel: EditAccountViewModel) {
    self.viewModel = viewModel
    
    self.accountName = viewModel.edittedAccount?.name ?? ""
    self.currency = viewModel.edittedAccount?.currency ?? ""
    self.useBiometry = viewModel.edittedAccount?.useBiometry ?? false
  }
  
  var body: some View {
    NavigationStack {
      ToastContainer(
        toastBarMessage: $toastMessage) {
          VStack(spacing: 8) {
            TextField("Account name", text: $accountName)
              .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Toggle(isOn: $useBiometry) {
              Text("Use biometry on app open?")
                .font(.body)
            }
            .padding(.bottom, 24)
            .padding(.horizontal, 8)
            
            VStack(spacing: 12) {
              TextField("Currency", text: $currency)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(viewModel.isEditingCurrencyDisabled)

              if !viewModel.isEditingCurrencyDisabled {
                HStack(spacing: 16) {
                  ForEach(PrederfinedCurrency.allCases, id: \.self) { currency in
                    Button(action: {
                      self.currency = currency.rawValue
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
            Text(viewModel.edittedAccount == nil ? "New account" : "Edit account")
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
                let result = await viewModel
                  .save(
                    accountName: accountName,
                    currency: currency,
                    useBiometry: useBiometry
                  )

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
