//
//  CurrencySelector.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 30.09.2025..
//

import SwiftUI

struct CurrencySelector: View {
  let currencies: [Currency]
  let colors: Colors
  let didSelectPredefinedCurrency: (Currency) -> Void
  
  var body: some View {
    HStack(spacing: 16) {
      ForEach(Currency.predefined, id: \.code) { currency in
        Button(action: {
          didSelectPredefinedCurrency(currency)
        }) {
          HStack {
            Spacer()
            Text(currency.code)
              .font(.headline)
              .foregroundStyle(colors.buttonText)
              .padding(.vertical, 8)
            Spacer()
          }
          .background(colors.buttonBackground)
          .cornerRadius(10)
        }
      }
    }
  }
}

#Preview {
  CurrencySelector(
    currencies: Currency.predefined,
    colors: .init(buttonBackground: .yellow, buttonText: .green),
    didSelectPredefinedCurrency: { currency in
      print("Did select currency: \(currency)")
    }
  )
}
