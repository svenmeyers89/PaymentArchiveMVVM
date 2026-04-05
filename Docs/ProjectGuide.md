# Project Guide

This document is the human- and agent-friendly source of truth for project conventions.

## 1. Project purpose & goals
- Document best practices for using MVVM in a SwiftUI-based project that relies on Swift concurrency and the Observation framework.
- The app must be representative of common real-life requirements in iOS apps.
- The project is intended to be public, and the architecture and concepts are a matter of open discussion.

## 2. Architecture
### 2.1 High-level pattern
- Architectural style: MVVM.
- Unidirectional data flow: emit state from data sources to views.
- Domain models must be immutable.
- Keep views focused only on presentation.
- Keep business, persistence, or networking logic in view models/services.

### 2.2 Responsibilities by layer
- `Screens`: UI composition, user interaction, feature state wiring.
- `ViewModel`: state transitions, orchestration, async tasks.
- `Services`: application and business services plus dependency boundaries.
- `DataStore`: data storage abstractions and implementations.
- `DataModel`: domain entities and domain-focused extensions.
- `PaymentArchive`: central data manager and source of unidirectional AppState data flow.

### 2.3 Dependency direction rules
- Inject dependencies through initializers or as function parameters whenever possible.
- Use `@Environment` only for strictly UI-related managers.
- Use dependencies that respect related layer responsibilities.

## 3. Folder structure and naming
### 3.1 Key directories
- `PaymentArchiveMVVM/Screens`
- `PaymentArchiveMVVM/Services`
- `PaymentArchiveMVVM/DataModel`
- `PaymentArchiveMVVM/Shared`
- `PaymentArchiveMVVM/Core`

## 4. UI conventions
### 4.1 SwiftUI composition
- Keep view bodies declarative and focused.
- Views may read domain model values directly for presentation (display, selection, simple formatting inputs).

### 4.2 Screens
- A Screen is a feature-level SwiftUI entry point.
- Each Screen should have a dedicated ViewModel.
- ViewModels may depend on service protocols/abstractions.
- Use a feature-specific `DataManager` protocol for actions involving domain data from persistence or network layers.
- ViewModel should delegate cohesive pieces of business logic to dedicated, screen-specific handler classes (SRP).
- View should interact only with the ViewModel; it must not call handler testclasses directly.
- Keep AppState-to-local state mapping explicit and isolated.
- Use `ScreenFactory` for screen creation and presentation flow wiring.
- Trigger navigation and modal presentation through the configured screen factory environment.

### 4.3 Shared views
- Shared views are reusable UI components.
- Extract reusable subviews as complexity of the Screen grows.
- Do not attach feature `ViewModel` logic to shared views; configure shared views from screen-level views.
- Expose user interactions through callback parameters.

### 4.4 UI-related file structure
- Store each Screen in a dedicated directory under `PaymentArchiveMVVM/Screens`.
- Name the Screen directory after the feature the Screen represents.
- Store Screen-specific handler classes in the `Helper` directory inside the Screen directory.
- Store auxiliary models for a Screen in the `Model` directory inside the Screen directory.
- Extract the Screen's `DataManager` protocol, configuration, and auxiliary models into `<FeatureName>+AddOns.swift`.
- Store each Shared view in a dedicated directory under `PaymentArchiveMVVM/Shared/View`.
- Name each Shared view directory after the view name.
- Keep view-specific extensions in the same feature directory and name them `<ViewName>+AddOns.swift`.

### 4.5 Theming and styling
- Centralize color/theme definitions in `Services/Theme`.
- Avoid hardcoded colors in feature views when theme tokens exist.
- Use `ColorPalette` as the app-specific color specification.
- Keep spacing, typography, and icon usage consistent across features.

### 4.6 Accessibility baseline
- Provide meaningful accessibility labels and hints for interactive controls.
- Support Dynamic Type where practical.

## 5. State, concurrency, and async rules
- Prefer Swift Concurrency (`async/await`) over callback-heavy code.
- Keep async work structured, cancellable, and scoped to lifecycle.
- Update UI state on the main actor when required to sustain the shared AppState data stream.
- Always use Swift concurrency concepts; avoid Combine.
- Prioritize the Observation framework; do not fall back to pre-iOS 17 patterns such as `@StateObject`, `@EnvironmentObject`, etc.

## 6. Data and persistence conventions
- Persistence implementations must stay behind store/service boundaries.
- Avoid leaking storage-specific types into domain/UI layers.
- Keep DTO/record mapping explicit and localized.
- Use stable identifiers and deterministic ordering where needed.
- Keep the data store API clear by documenting all data conventions (such as sort order of returned models).

## 7. Testing strategy
### 7.1 Providing testability
- Separate responsibilities and break business logic into small classes.
- Follow dependency injection guidelines stated in #2.3 to facilitate the use of mocked data.

### 7.2 Unit tests
- Prefer deterministic fixtures and explicit assertions.
- Use clear behavior-based names (Given/When/Then style optional).

## 8. How to add a new feature
1. Create a screen folder under `Screens/` following the UI convention in section 4.
2. Reuse shared components before introducing new shared UI.
3. Add/update service abstractions if new business operations are required.
4. Add unit tests for logic.

## 9. Documentation map
- Root agent contract: [AGENTS.md](../AGENTS.md)
- Public project intro: [README.md](../README.md)
- Deep conventions: this file
