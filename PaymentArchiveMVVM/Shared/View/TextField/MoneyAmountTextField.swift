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
  let colors: Colors
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Add the payment amount")
        .font(.title2)
        .foregroundStyle(colors.title)
      
      HStack(spacing: 12) {
        TextField(
          "Payment amount",
          text: $amount
        )
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .keyboardType(.decimalPad)
        .foregroundStyle(colors.textField)

        Text(currency)
          .font(.headline)
          .foregroundStyle(colors.currency)
      }
    }
    .background(colors.background)
  }
}

extension MoneyAmountTextField {
  struct Colors {
    let background: Color
    let title: Color
    let textField: Color
    let currency: Color
  }
}

#Preview {
  @Previewable @State var amount: String = ""
  MoneyAmountTextField(
    amount: $amount,
    currency: "EUR",
    colors: .init(
      background: .green,
      title: .black,
      textField: .orange,
      currency: .black
    )
  )
}
