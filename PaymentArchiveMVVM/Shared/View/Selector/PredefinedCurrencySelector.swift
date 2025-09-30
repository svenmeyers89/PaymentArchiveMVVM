//
//  PredefinedCurrencySelector.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 30.09.2025..
//

import SwiftUI

struct PredefinedCurrencySelector: View {
  let predefinedCurrencies: [PrederfinedCurrency]
  let colors: Colors
  let didSelectPredefinedCurrency: (PrederfinedCurrency) -> Void
  
  var body: some View {
    HStack(spacing: 16) {
      ForEach(PrederfinedCurrency.allCases, id: \.self) { currency in
        Button(action: {
          didSelectPredefinedCurrency(currency)
        }) {
          HStack {
            Spacer()
            Text(currency.symbol)
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

extension PredefinedCurrencySelector {
  struct Colors {
    let background: Color
    let buttonBackground: Color
    let buttonText: Color
  }
}

#Preview {
  PredefinedCurrencySelector(
    predefinedCurrencies: PrederfinedCurrency.allCases,
    colors: .init(background: .blue, buttonBackground: .yellow, buttonText: .green),
    didSelectPredefinedCurrency: { currency in
      print("Did select currency: \(currency)")
    }
  )
}
