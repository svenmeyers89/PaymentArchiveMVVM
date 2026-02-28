//
//  SwiftDataStoreLocationResolver.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.02.2026..
//

import Foundation

protocol SwiftDataStoreLocationResolver {
  func storeURL() throws -> URL
}

struct ApplicationSandboxSwiftDataStoreLocationResolver {
  enum CachingType {
    case temporary // Use only for testing
    case persistent
  }

  private let fileManager: FileManager
  private let cachingType: CachingType
  
  private let appDirectoryName: String = "PaymentArchiveMVVM"
  private let databaseFileName: String = "PaymentArchive.sqlite"
  
  init(
    fileManager: FileManager = .default,
    cachingType: CachingType = .persistent
  ) {
    self.fileManager = fileManager
    self.cachingType = cachingType
  }

  private func storeDirectoryURL() throws -> URL {
    let baseDirectoryURL: URL = try {
      switch cachingType {
      case .persistent:
        guard let applicationSupportURL = fileManager.urls(
          for: .applicationSupportDirectory,
          in: .userDomainMask
        ).first else {
          throw SwiftDataPersistenceStoreError.missingApplicationSupportDirectory
        }
        return applicationSupportURL
      case .temporary:
        return fileManager.temporaryDirectory
      }
    }()

    return baseDirectoryURL
      .appendingPathComponent(appDirectoryName, isDirectory: true)
  }
}

extension ApplicationSandboxSwiftDataStoreLocationResolver: SwiftDataStoreLocationResolver {
  func storeURL() throws -> URL {
    let appDirectoryURL = try storeDirectoryURL()

    try fileManager.createDirectory(
      at: appDirectoryURL,
      withIntermediateDirectories: true
    )

    return appDirectoryURL
      .appendingPathComponent(databaseFileName)
  }
}
