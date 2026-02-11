//
//  MainBroadcaster.swift
//  AsyncOperators
//
//  Created by Sven Majeric on 10.02.2026..
//

import Foundation

@MainActor
public final class MainBroadcaster<T: Sendable> {
  private var continuations: [UUID: AsyncStream<T>.Continuation] = [:]
  
  public init(value: T) {
    self.value = value
  }
  
  public var value: T {
    didSet {
      for continuation in continuations.values {
        continuation.yield(value)
      }
    }
  }

  public func makeStream() -> AsyncStream<T> {
    AsyncStream { continuation in
      let id = UUID()
      continuations[id] = continuation

      continuation.yield(value)
      
      continuation.onTermination = { [weak self] _ in
        Task { @MainActor in
          self?.continuations.removeValue(forKey: id)
        }
      }
    }
  }
}
