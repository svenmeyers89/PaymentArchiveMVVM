//
//  PaymentView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 13.08.2025..
//

import SwiftUI

struct PaymentView: View {
  let payment: Payment
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
        Text("\(payment.amount)")
          .font(.headline)
          .foregroundStyle(colors.paymentAmount)
      } label: {
        VStack(alignment: .leading) {
          Text("\(payment.timestamp)")
            .font(.headline)
            .foregroundStyle(colors.paymentDateTime)
          Text("\(payment.category.name)")
            .font(.caption)
            .foregroundStyle(colors.categoryName)
        }
      }
    }
  }
}

extension PaymentView {
  struct Colors {
    let background: Color
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
        accountId: "1", amount: 12.5, category: .presents
      ),
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
