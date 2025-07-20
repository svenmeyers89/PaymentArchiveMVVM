//
//  MoneyAmountTextField.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct MoneyAmountTextField: View {
  @Binding var amount: String
  let currency: String
  //let colors: EditPaymentColors.TextBox
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Add the payment amount")
        .font(.title2)
        //.foregroundStyle(colors.title)
      
      HStack(spacing: 12) {
        TextField(
          "Payment amount",
          text: $amount
        )
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .keyboardType(.decimalPad)
        //.foregroundStyle(.headline)

        Text(currency)
          .font(.headline)
          //.foregroundStyle(colors.currencyTitle)
      }
    }
  }
}

#Preview {
  @Previewable @State var amount: String = ""
  MoneyAmountTextField(
    amount: $amount,
    currency: "EUR"
  )
}
