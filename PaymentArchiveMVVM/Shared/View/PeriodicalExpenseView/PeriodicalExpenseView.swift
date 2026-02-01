//
//  PeriodicalExpenseView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 27.01.2026..
//

import SwiftUI

extension PaymentGroup {
  fileprivate func expenseDescription(
    now: Date = .init(),
    calendar: Calendar = Calendar.appCalendar
  ) -> String {
    guard let dateRepresentative else {
      fatalError("Invalid payment group!")
    }
    switch kind {
    case .dailyPayments:
      if calendar.isDateInToday(dateRepresentative) {
        return "Today"
      } else if calendar.isDateInYesterday(dateRepresentative) {
        return "Yesterday"
      } else if let daysAgo = calendar.dayDifference(from: now, to: dateRepresentative),
         daysAgo < 7 {
        let f = DateStyle.weekdayDayMonth
        f.locale = Locale.appLocale
        return f.string(from: dateRepresentative)
      } else {
        var dateStyle = DateStyle.dateTime
        dateStyle.locale = Locale.appLocale
        return dateStyle.format(dateRepresentative)
      }

    case .monthlyStats:
      if calendar.isDate(dateRepresentative, inMonthOf: now) {
        return "This month"
      } else {
        let f = DateStyle.monthYear
        f.locale = Locale.appLocale
        return f.string(from: dateRepresentative)
      }
    }
  }
}

struct PeriodicalExpenseView: View {
  let paymentGroup: PaymentGroup
  
  var body: some View {
    HStack {
      Text(paymentGroup.expenseDescription())
        .font(.title2)
      Spacer()
      Text(
        paymentGroup.currency
          .string(
            from: paymentGroup.totalAmountMinorUnits,
            appendCurrencyCode: true
          )
      )
      .font(.headline)
    }
  }
}

#Preview {
  PeriodicalExpenseView(
    paymentGroup: .init(
      payments: [Payment(accountId: "1", amountMinorUnits: 120, category: .groceries)],
      currency: .usd,
      kind: .dailyPayments,
      totalAmountMinorUnits: 120
    )
  )
}
