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
    
    let state = stateWrapper.state
    
    switch state {
    case .loadingInitialState:
      return .loading
    case .shouldOnboard:
      return .onboarding
    case let .didLoad(paymentGroups, currency, selectedAccountId):
      return .listView(sections: paymentGroups, currency: currency, selectedAccountId: selectedAccountId)
    }
  }

  
  var allPaymentCategories: [Payment.Category] {
    paymentArchiveCategorySelector.allPaymentCategories
  }
  
  var selectedPaymentCategories: Set<Payment.Category> {
    paymentArchiveCategorySelector.selectedPaymentCategories
  }

  private let stateWrapper: PaymentArchiveStateWrapper
  private let paymentArchive: PaymentArchive
  private let paymentArchiveCategorySelector: PaymentArchiveCategorySelector
  
  private var errorMessage: String?

  init(paymentArchive: PaymentArchive) {
    self.paymentArchive = paymentArchive
    self.paymentArchiveCategorySelector = .init(
      allPaymentCategories: Payment.Category.allCases,
      selectedPaymentCategories: Set<Payment.Category>(Payment.Category.allCases)
    )
    self.stateWrapper = .init(
      paymentArchive: paymentArchive,
      paymentGroupBuilder: PaymentArchiveGroupBuilder(),
      paymentArchiveCategorySelector: paymentArchiveCategorySelector
    )
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
    paymentArchiveCategorySelector.didConfirmSelection(paymentCategories: paymentCategories)
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
}

@MainActor @Observable
final class PaymentArchiveCategorySelector {
  let allPaymentCategories: [Payment.Category]
  private(set) var selectedPaymentCategories: Set<Payment.Category>
  
  init(
    allPaymentCategories: [Payment.Category],
    selectedPaymentCategories: Set<Payment.Category>
  ) {
    self.allPaymentCategories = allPaymentCategories
    self.selectedPaymentCategories = selectedPaymentCategories
  }
  
  func didConfirmSelection(paymentCategories: Set<Payment.Category>) {
    selectedPaymentCategories = paymentCategories
  }
}

@MainActor @Observable
final class PaymentArchiveStateWrapper {
  enum WrappedState {
    case loadingInitialState
    case shouldOnboard
    case didLoad(paymentGroups: [PaymentGroup], currency: Currency, selectedAccountId: String)
  }

  private(set) var state: WrappedState = .loadingInitialState
  
  private let paymentArchive: PaymentArchive
  private let paymentGroupBuilder: PaymentArchiveGroupBuilder
  private let paymentArchiveCategorySelector: PaymentArchiveCategorySelector
  
  init(
    paymentArchive: PaymentArchive,
    paymentGroupBuilder: PaymentArchiveGroupBuilder,
    paymentArchiveCategorySelector: PaymentArchiveCategorySelector
  ) {
    self.paymentArchive = paymentArchive
    self.paymentGroupBuilder = paymentGroupBuilder
    self.paymentArchiveCategorySelector = paymentArchiveCategorySelector
    
    observeState()
  }

  private func observeState() {
    withObservationTracking {
      _ = paymentArchive.state
      _ = paymentArchiveCategorySelector.selectedPaymentCategories
    } onChange: { [weak self] in
      Task {
        await self?.regenerateState()
        await self?.observeState()
      }
    }
  }

  private func regenerateState() async {
    guard let state = paymentArchive.state else {
      self.state = .loadingInitialState
      return
    }
    
    guard let selectedAccount = state.selectedAccount else {
      self.state = .shouldOnboard
      return
    }
    
    let allPayments: [Payment] = state.payments[selectedAccount.id] ?? []
    let selectedPaymentCategories = paymentArchiveCategorySelector.selectedPaymentCategories
    let filteredPayments: [Payment] = allPayments.filter { selectedPaymentCategories.contains($0.category) }
    let paymentGroups = await paymentGroupBuilder.groupPayments(using: filteredPayments, currency: selectedAccount.currency)
    
    self.state = .didLoad(paymentGroups: paymentGroups, currency: selectedAccount.currency, selectedAccountId: selectedAccount.id)
  }
}

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
