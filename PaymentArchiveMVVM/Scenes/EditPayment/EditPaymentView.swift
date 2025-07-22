//
//  EditPaymentView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct EditPaymentView: View {
  /*@StateObject*/ private var viewModel: EditPaymentViewModel

  init(viewModel: @autoclosure @escaping () -> EditPaymentViewModel) {
    //_viewModel = StateObject(wrappedValue: viewModel())
    self.viewModel = viewModel()
  }

  var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
  }
}

#Preview {
  EditPaymentView(
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
