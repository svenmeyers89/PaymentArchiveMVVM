//
//  MoneyAmountTextField.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct MoneyAmountTextField: View {
  @Binding var amount: Float?
  let currency: String
  let colors: Colors

  @Environment(\.locale) private var locale
  @State private var cents: Int
  private let formatter: NumberFormatter = .init()
  
  init(
    amount: Binding<Float?>,
    currency: String,
    colors: Colors
  ) {
    self._amount = amount
    self.currency = currency
    self.colors = colors
    self.cents = Int((amount.wrappedValue ?? 0) * 100.0)
    
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.locale = locale
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Add the payment amount")
        .font(.title2)
        .foregroundStyle(colors.title)
      
      HStack(spacing: 12) {
        TextField(
          "Payment amount", // This guy is never shown
          text: Binding(
            get: {
              formattedAmount
            },
            set: { newValue in
              // Strip non-digit characters
              let digits = newValue.compactMap { $0.wholeNumberValue }

              if digits.isEmpty {
                // User hit backspace when only one digit was left
                cents = 0
              } else {
                // Compose new cents value from digits
                let number = digits.reduce(0) { $0 * 10 + $1 }
                cents = number
              }
            }
          )
        )
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .keyboardType(.decimalPad)
        .foregroundStyle(colors.textField)
        .onChange(of: cents) { _, newValue in
          let amount = Float(newValue) / 100.0
          self.amount = amount
        }

        Text(currency)
          .font(.headline)
          .foregroundStyle(colors.currency)
      }
    }
    .background(colors.background)
  }
  
  private var formattedAmount: String {
    var amount = Decimal(cents) / 100
    if amount < 0.01 {
      amount *= 10
    }
    return formatter
      .string(from: amount as NSDecimalNumber) ?? ""
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
  @Previewable @State var amount: Float? = nil
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
