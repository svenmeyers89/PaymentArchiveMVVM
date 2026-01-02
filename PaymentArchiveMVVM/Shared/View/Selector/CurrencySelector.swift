//
//  PredefinedCurrencySelector.swift
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
    .background(colors.background)
  }
}

extension CurrencySelector {
  struct Colors {
    let background: Color
    let buttonBackground: Color
    let buttonText: Color
  }
}

#Preview {
  CurrencySelector(
    currencies: Currency.predefined,
    colors: .init(background: .blue, buttonBackground: .yellow, buttonText: .green),
    didSelectPredefinedCurrency: { currency in
      print("Did select currency: \(currency)")
    }
  )
}
