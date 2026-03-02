//
//  MoneyAmountTextField.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct MoneyAmountTextField: View {
  @Binding var amountMinorUnits: Int
  let currency: Currency
  let colors: Colors
  
  @State private var text: String = ""
  
  private var keyboardType: UIKeyboardType {
    if currency.minorUnitExponent == 0 {
      .numberPad
    } else {
      .decimalPad
    }
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Add the payment amount")
        .font(.title2)
        .foregroundStyle(colors.title)
      
      HStack(spacing: 12) {
        TextField("Payment amount", text: $text)
          .keyboardType(keyboardType)
          .textFieldStyle(.roundedBorder)
          .foregroundStyle(colors.textField)
          .onChange(of: text) { _, newValue in
            updateMinorUnits(from: newValue)
          }

        Text(currency.code)
          .font(.headline)
          .foregroundStyle(colors.currency)
      }
    }
    .onAppear {
      text = formattedAmount(from: amountMinorUnits)
    }
    .onChange(of: amountMinorUnits) { _, newValue in
      let formatted = formattedAmount(from: newValue)
      if text != formatted {
        text = formatted
      }
    }
  }
  
  private func updateMinorUnits(from text: String) {
    let digits = text.compactMap(\.wholeNumberValue)

    if digits.isEmpty {
      amountMinorUnits = 0
    } else {
      amountMinorUnits = digits.reduce(0) { $0 * 10 + $1 }
    }
  }
  
  private func formattedAmount(from minorUnits: Int) -> String {
    currency.string(from: minorUnits, appendCurrencyCode: false)
  }
}

extension MoneyAmountTextField {
  struct Colors {
    let title: Color
    let textField: Color
    let currency: Color
  }
}

#Preview {
  @Previewable @State var amount: Int = 0
  MoneyAmountTextField(
    amountMinorUnits: $amount,
    currency: Currency.yen,
    colors: .init(
      title: .black,
      textField: .orange,
      currency: .black
    )
  )
}
