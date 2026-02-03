//
//  PaymentArchiveGroupBuilder.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.02.2026..
//

import Foundation

actor PaymentArchiveGroupBuilder {
  private func getKey(for date: Date, calendar: Calendar, groupKind: PaymentGroup.Kind) -> String {
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    guard let year = components.year,
          let month = components.month,
          let day = components.day else {
      fatalError("Invalid date components")
    }
    switch groupKind {
    case .dailyPayments:
      return "\(year)-\(month)-\(day)"
    case .monthlyStats:
      return "\(year)-\(month)"
    }
  }
  
  func groupPayments(
    using payments: [Payment],
    currency: Currency,
    calendar: Calendar = Calendar.appCalendar
  ) -> [PaymentGroup] {
    var dailyPayments: [String: [Payment]] = [:]
    var monthlyPayments: [String: [Payment]] = [:]
    var allKeys: [String] = []
    
    for payment in payments {
      let monthKey = getKey(for: payment.createdAt, calendar: calendar, groupKind: .monthlyStats)
      if var monthlyPaymentsForKey = monthlyPayments[monthKey] {
        monthlyPaymentsForKey.append(payment)
        monthlyPayments[monthKey] = monthlyPaymentsForKey
      } else {
        monthlyPayments[monthKey] = [payment]
        allKeys.append(monthKey)
      }
      
      let dayKey = getKey(for: payment.createdAt, calendar: calendar, groupKind: .dailyPayments)
      if var dailyPaymentsForKey = dailyPayments[dayKey] {
        dailyPaymentsForKey.append(payment)
        dailyPayments[dayKey] = dailyPaymentsForKey
      } else {
        dailyPayments[dayKey] = [payment]
        allKeys.append(dayKey)
      }
    }
    
    var paymentGroups: [PaymentGroup] = []
    for key in allKeys {
      if let monthlyPaymentsForKey = monthlyPayments[key] {
        paymentGroups.append(
          .init(
            payments: monthlyPaymentsForKey,
            currency: currency,
            kind: .monthlyStats,
            totalAmountMinorUnits: monthlyPaymentsForKey.map { $0.amountMinorUnits }.reduce(0, +)
          )
        )
      } else if let dailyPaymentsForKey = dailyPayments[key] {
        paymentGroups.append(
          .init(
            payments: dailyPaymentsForKey,
            currency: currency,
            kind: .dailyPayments,
            totalAmountMinorUnits: dailyPaymentsForKey.map { $0.amountMinorUnits }.reduce(0, +)
          )
        )
      }
    }
    return paymentGroups
  }
}
