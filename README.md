# PaymentArchiveMVVM

This project is an architectural experiment focused on a stable, predictable stream of `AppState` data from the central data manager (`PaymentArchive`) to the UI layer and its view models.

## Summary
- `PaymentArchive` is the single source of truth for global state and produces a stable stream of `AppState` updates.
- View models observe that stream and act as the boundary between global state and views.
- Each view model collects the relevant subset of state and reshapes it to fit its view’s needs.
- Views stay lightweight and reactive, relying on view models for presentation-ready data.

## Intent
The goal is to validate an MVVM-style flow where state is centralized, updates are consistent, and the UI can remain simple and testable.
