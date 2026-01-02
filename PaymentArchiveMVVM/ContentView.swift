//
//  ContentView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      List {
        PaymentView(
          payment: .init(
            accountId: "1",
            amountMinorUnits: 1250,
            category: .accommodation
          ),
          currency: Currency.eur,
          colors: .init(
            background: .white,
            categoryIcon: .init(iconBackground: .white, iconTint: .blue),
            paymentDateTime: .secondary,
            categoryName: .primary,
            paymentAmount: .primary
          )
        )
      }
      .listStyle(.insetGrouped)
    }
}

#Preview {
    ContentView()
}
