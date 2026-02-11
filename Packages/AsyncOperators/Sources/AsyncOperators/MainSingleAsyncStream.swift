//
//  MainSingleAsyncStream.swift
//  AsyncOperators
//
//  Created by Sven Majeric on 10.02.2026..
//

/// Utility handler for a single stream.
/// In case of multiple consumers, use Broadcaster instead.
@MainActor
public final class MainSingleAsyncStream<T: Sendable> {
  private var continuation: AsyncStream<T>.Continuation?
  
  public init(value: T) {
    self.value = value
  }
  
  public var value: T {
    didSet {
      continuation?.yield(value)
    }
  }
  
  public lazy var stream: AsyncStream<T> = {
    AsyncStream { continuation in
      self.continuation = continuation
      
      continuation.yield(value)
      
      continuation.onTermination = { [weak self] _ in
        Task { @MainActor in
          self?.continuation = nil
        }
      }
    }
  }()
}
