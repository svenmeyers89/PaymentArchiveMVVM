//
//  DemoPersistenceStoreBuilder.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 01.04.2026..
//

protocol DemoDataStoreSeeder: Sendable {
  func seedDemoData(into store: PersistenceStore) async throws
}
