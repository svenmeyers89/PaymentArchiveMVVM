//
//  PaymentView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 13.08.2025..
//

import SwiftUI

struct PaymentView: View {
  let payment: Payment
  
  var body: some View {
    HStack {
      CategoryIcon(
        iconSystemName: payment.category.symbolName,
        side: 24,
        colors: .init(
          iconBackground: .blue,
          iconTint: .white
        )
      )
      // Uses LabeledContent to get support for dynamic text
      LabeledContent {
        Text("\(payment.amount)")
          .font(.headline)
          .foregroundStyle(.secondary)
      } label: {
        VStack(alignment: .leading) {
          Text("\(payment.timestamp)")
            .font(.headline)
          Text("\(payment.category.name)")
            .font(.caption)
        }
      }
    }
  }
}

#Preview {
  List {
    PaymentView(
      payment: .init(
        accountId: "1", amount: 12.5, category: .presents
      )
    )
  }
  .listStyle(.insetGrouped)
}
