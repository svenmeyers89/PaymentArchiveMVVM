# PaymentArchiveMVVM

This project is an architectural experiment focused on a stable, predictable stream of `AppState` data from the central data manager (`PaymentArchive`) to the UI layer and its view models.

## Summary
- `PaymentArchive` is the single source of truth for global state and produces a stable stream of `AppState` updates.
- View models observe that stream and act as the boundary between global state and views.
- Each view model collects the relevant subset of state and reshapes it to fit its view’s needs.
- Views stay lightweight and reactive, relying on view models for presentation-ready data.

## Intent
The goal is to validate an MVVM-style flow where state is centralized, updates are consistent, and the UI can remain simple and testable.

## References

The `Docs` folder contains useful documents that describe the architecture:
- [`ProjectGuide.md`](Docs/ProjectGuide.md) - provides a comprehensive set of rules; it is friendly for both users and AI agents.
- [`DataFlow.md`](Docs/DataFlow.md) - explains the unidirectional data flow, summarizes its requirements, and provides a technical overview.
- [`TODO.md`](Docs/TODO.md) - backlog of upcoming tasks.

[`AGENTS.md`](AGENTS.md) defines general rules that help AI agents follow the architectural guidelines. These guidelines are open to further discussion and continuous improvement.
