//
//  DemoPersistenceStoreBuilder.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 01.04.2026..
//

import Foundation

protocol DemoDataStoreSeeder: Sendable {
  func seedDemoData(into store: PersistenceStore) async throws
}

actor RandomizedDataStoreSeeder: DemoDataStoreSeeder {
  func seedDemoData(into store: PersistenceStore) async throws {
    let accountId = UUID().uuidString
    let currency = Currency.eur
    let account = Account(
      id: accountId,
      name: "Demo Account",
      currency: currency,
      useBiometry: false
    )

    try await store.saveAccount(account)

    let calendar = Calendar.current
    let now = Date()

    for monthOffset in 0..<4 { // current month and previous 3 months
      guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) else { continue }
      let dayRange = calendar.range(of: .day, in: .month, for: monthDate)
      let paymentCount = Int.random(in: 10...20)

      for index in 0..<paymentCount {
        let day = dayRange?.randomElement() ?? 1
        let hour = Int.random(in: 0..<24)
        let minute = Int.random(in: 0..<60)
        var components = calendar.dateComponents([.year, .month], from: monthDate)
        components.day = day
        components.hour = hour
        components.minute = minute

        let createdAt = calendar.date(from: components) ?? now
        let forceCurrentDate = (monthOffset == 0 && index == 0)
        let paymentDate = forceCurrentDate ? now : createdAt

        let payment = Payment(
          createdAt: paymentDate, accountId: accountId,
          amountMinorUnits: Int.random(in: 500...20_000),
          category: Payment.Category.allCases.randomElement() ?? .groceries,
          note: nil
        )

        try await store.savePayment(payment)
      }
    }
  }
}

