//
//  PaymentView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 13.08.2025..
//

import SwiftUI

struct PaymentView: View {
  let payment: Payment
  let currency: Currency
  let colors: Colors
  
  var body: some View {
    HStack {
      CategoryIcon(
        iconSystemName: payment.category.symbolName,
        side: 24,
        colors: colors.categoryIcon
      )
      // Uses LabeledContent to get support for dynamic text
      LabeledContent {
        Text(
          currency
            .string(
              from: payment.amountMinorUnits,
              appendCurrencyCode: true
            )
        )
        .font(.headline)
        .foregroundStyle(colors.paymentAmount)
      } label: {
        VStack(alignment: .leading) {
          Text(DateStyle.timeOnly.string(from: payment.createdAt))
            .font(.headline)
            .foregroundStyle(colors.paymentDateTime)
          Text("\(payment.category.rawValue)")
            .font(.caption)
            .foregroundStyle(colors.categoryName)
        }
      }
    }
  }
}

extension PaymentView {
  struct Colors {
    let categoryIcon: CategoryIcon.Colors
    let paymentDateTime: Color
    let categoryName: Color
    let paymentAmount: Color
  }
}

#Preview {
  List {
    PaymentView(
      payment: .init(
        accountId: "1", amountMinorUnits: 125, category: .presents
      ),
      currency: Currency.gbp,
      colors: .init(
        categoryIcon: .init(iconBackground: .white, iconTint: .blue),
        paymentDateTime: .secondary,
        categoryName: .primary,
        paymentAmount: .primary
      )
    )
  }
  .listStyle(.insetGrouped)
}
