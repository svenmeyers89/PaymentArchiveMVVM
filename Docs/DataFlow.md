# Data Flow

## `PaymentArchive` requirements

1. `PaymentArchive` is the central data manager and the only class responsible for managing `AppState`.
2. Data flow must be unidirectional, meaning that `PaymentArchive` is the starting point of the data stream.
3. The data stream must be shareable, which means that it must support having multiple observers at a time.
4. `AppState` must be easily convertible into local state for every screen.

## `AsyncSequence` vs `@Observable` (with `iOS 17` support)

At first, the `Observation` framework seems like a logical choice.
`PaymentArchive` can be made `@Observable` and have a `private(set) var appState: AppState` property. This would satisfy the first three requirements.

However, what if a `ViewModel` should do some asynchronous work after `appState` is changed, which results in a local state change?
If the conversion to local state can be done synchronously, the `ViewModel` could put all the logic into a computed property.
Unfortunately, asynchronous actions make the conversion more complex.

Prior to `iOS 17` and the `Observation` framework, an `ObservableObject` would mark observable properties with `@Published`.
If a `ViewModel` should change local state asynchronously on `appState` change, it would be able to subscribe to `$appState`.
Sadly, with the `Observation` framework there is no `Combine`-based support anymore.
Instead, since the minimum supported iOS version is `iOS 17`, we should use the `withObservationTracking` API, which, for starters, really doesn't look nice. :')
In one of my previous `PaymentArchive` versions, I managed to build a more-or-less stable data flow having `PaymentArchive` declared as `@Observable` and using `withObservationTracking` in `ViewModel`s.
With that setup, I noticed `SwiftUI` refreshing quite unexpectedly when that callback would fire, which indicated that the closure was probably reading more than intended. This was particularly strange as I was referencing merely `appState` in the callback, which was a straight one-liner.

So I started looking for a solution based on `AsyncSequence`.
I realized that it is really easy to have a shareable centralized data flow after I implemented the `MainBroadcaster` utility.
This means that `PaymentArchive` requirements 1-3 were very easy to satisfy.
Finally, requirement #4 becomes straightforward, since every `ViewModel` can iterate through the async sequence to get any change and then respond either synchronously or asynchronously.

In `iOS 26`, Apple added the `Observations` concept conforming to `AsyncSequence` to the `Observation` framework, which confirmed I had been on the right track before.

## Conclusion

- Organize data flow so that `appState` is conveyed to `ViewModel`s, the last barrier before mapping data to UI, with `AsyncStream`s.
- Take advantage of `AsyncOperators`, such as `CombineLatest`, to create a final data stream for local data.
- Use a single handler for each data stream to separate responsibilities clearly.
- Keep using a computed property to convey local state to the `View`. That way, the `View` will have a single source of data.
