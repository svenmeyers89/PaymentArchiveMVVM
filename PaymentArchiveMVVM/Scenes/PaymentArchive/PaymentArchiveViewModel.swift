//
//  PaymentArchiveViewModel.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 03.09.2025..
//

// temp
import Foundation

import Observation

@MainActor @Observable
final class PaymentArchiveViewModel {
  var contentType: PaymentArchiveView.ContentType {
    if let errorMessage {
      return .error(errorMessage)
    }
    
    guard let state = paymentArchive.state else {
      return .loading
    }
    
    guard let selectedAccount = state.selectedAccount else {
      return .onboarding
    }
    
    let paymentGroups = self.recomuputePaymentGroups()
    
    return .listView(sections: paymentGroups, currency: selectedAccount.currency, selectedAccountId: selectedAccount.id)
  }

  let allPaymentCategories: [Payment.Category] = Payment.Category.allCases
  private(set) var selectedPaymentCategories: Set<Payment.Category> = .init(Payment.Category.allCases)

  private let dataSource: PaymentArchiveDataSource = .init()
  // private var paymentGroups: [PaymentGroup] = []
  
  private var errorMessage: String?
  
  private let paymentArchive: PaymentArchive

  init(paymentArchive: PaymentArchive) {
    self.paymentArchive = paymentArchive
  }

  func loadContent() async {
    do {
      try await paymentArchive.loadInitialState()
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  func didConfirmSelection(paymentCategories: Set<Payment.Category>) {
    selectedPaymentCategories = paymentCategories
//    Task {
//      self.paymentGroups = await recomuputePaymentGroups()
//    }
  }
  
  func recomuputePaymentGroups() -> [PaymentGroup] {
    guard let state = paymentArchive.state,
          let account = state.selectedAccount else {
      return []
    }

    let allPayments = state.payments[account.id] ?? []

    let filtered = allPayments.filter {
      selectedPaymentCategories.contains($0.category)
    }

    let paymentGroups = dataSource.groupPayments(using: filtered, currency: account.currency)
    return paymentGroups
  }
}

enum PaymentGroupUpdateError: Error {
  case paymentDateDoesNotBelongToGroup
}

struct PaymentGroup {
  enum Kind {
    case monthlyStats
    case dailyPayments
  }
  
  enum UpdateType {
    case append
    case reset
  }
  
  let payments: [Payment]
  let currency: Currency
  let kind: Kind
  let totalAmountMinorUnits: Int
  
  init(payments: [Payment] = [],
       currency: Currency, kind: Kind,
       totalAmountMinorUnits: Int = 0) {
    self.payments = payments
    self.currency = currency
    self.kind = kind
    self.totalAmountMinorUnits = totalAmountMinorUnits
  }
  
  var id: String {
    var kindId = "\(kind)"
    if let dateRepresentative = dateRepresentative {
      kindId += "_\(dateRepresentative)"
    }
    return kindId
  }
  
  var dateRepresentative: Date? {
    payments.first?.createdAt
  }
  
  func doesDateBelongToGroup(_ date: Date, calendar: Calendar) -> Bool {
    guard let dateRepresentative = dateRepresentative else {
      return false
    }

    switch kind {
    case .monthlyStats:
      return calendar.isDate(date, inMonthOf: dateRepresentative)
    case .dailyPayments:
      return calendar.isDate(date, inDayOf: dateRepresentative)
    }
  }
  
  func updated(with payment: Payment, updateType: UpdateType, calendar: Calendar) -> PaymentGroup {
    switch updateType {
    case .append:
      guard payments.isEmpty || doesDateBelongToGroup(payment.createdAt, calendar: calendar) else {
        return self
      }
      var updatedPayments = payments
      updatedPayments.append(payment)
      let updatedTotalAmountMinorUnits = totalAmountMinorUnits + payment.amountMinorUnits
      return PaymentGroup(
        payments: updatedPayments,
        currency: currency,
        kind: kind,
        totalAmountMinorUnits: updatedTotalAmountMinorUnits
      )
    case .reset:
      return PaymentGroup(
        payments: [payment],
        currency: currency,
        kind: kind,
        totalAmountMinorUnits: payment.amountMinorUnits
      )
    }
  }
}

struct PaymentArchiveDataSource {
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
