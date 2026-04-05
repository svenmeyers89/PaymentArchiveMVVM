//
//  DemoDataStoreConfiguration.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 05.04.2026..
//

struct DemoDataStoreConfiguration: Sendable {
  let dataStore: PersistenceStore
  let dataStoreSeeder: DemoDataStoreSeeder
}
