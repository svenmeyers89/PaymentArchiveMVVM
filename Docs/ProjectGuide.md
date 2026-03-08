# Project Guide

This document is the human- and agent-friendly source of truth for project conventions.

## 1. Project overview (TBD)
- Purpose of the app:
- Core user workflows:
- Non-goals:

## 2. Architecture (TBD)
### 2.1 High-level pattern
- Architectural style: MVVM
- Layering: `Screens` -> `Services` -> `Persistence`
- Domain model location: `PaymentArchiveMVVM/DataModel`

### 2.2 Responsibilities by layer
- `Screens`: UI composition, user interaction, feature state wiring.
- `ViewModel`: presentation logic, orchestration, async tasks, state transitions.
- `Services`: application/business services and dependency boundaries.
- `PersistenceStore`: data storage abstractions and implementations.
- `DataModel`: domain entities and domain-focused extensions.

### 2.3 Dependency direction rules
- UI must not directly own persistence details.
- View models may depend on service protocols/abstractions.
- Persistence implementations must stay behind store/service boundaries.

## 3. Folder structure and naming (TBD)
### 3.1 Key directories
- `PaymentArchiveMVVM/Screens`
- `PaymentArchiveMVVM/Services`
- `PaymentArchiveMVVM/DataModel`
- `PaymentArchiveMVVM/Shared`
- `PaymentArchiveMVVMTests`
- `PaymentArchiveMVVMUITests`

### 3.2 Naming conventions
- Types: `PascalCase`
- Properties/functions: `camelCase`
- Files: one primary type per file, filename matches type name
- Extensions: `Type+Concern.swift` (for example, `Currency+Formatting.swift`)

### 3.3 Feature file layout (template)
- `Screens/FeatureName/FeatureNameView.swift`
- `Screens/FeatureName/FeatureNameViewModel.swift`
- `Screens/FeatureName/FeatureNameView+AddOns.swift` (screen-local models and protocols)
- `Screens/FeatureName/Model/...` (if feature-local model types are needed)
- `Screens/FeatureName/Helper/...` (for focused helpers only)

## 4. UI conventions
### 4.1 SwiftUI composition
- Keep view bodies declarative and focused.
- Extract reusable subviews as complexity grows.
- Keep business rules out of `View` types.
- Keep unidirectional data flow: `AppState -> ViewModel -> View`.
- Inject configuration and dependencies through initializers when possible.
- Provide UI-specific actions through environment values only when shared across multiple views.
- Views may read domain model values directly for presentation (display, selection, simple formatting inputs).
- Any non​-trivial mapping, business logic, validation, persistence​/network interaction, or cross​-model orchestration must stay outside the ​View (​View​Model​/handler​/service).

### 4.2 Screens
- A Screen is a feature-level SwiftUI entry point under `PaymentArchiveMVVM/Screens`.
- Each Screen should have a dedicated `ViewModel`.
- `ViewModel` types should be `@Observable` and `@MainActor` when they own UI state.
- Keep business logic in `ViewModel` or dedicated handler/service types, not in views.
- Avoid turning `ViewModel` into a bottleneck; extract cohesive responsibilities into focused types.
- Keep AppState-to-local state mapping explicit and isolated.
- Screen views should not directly call handlers owned by the `ViewModel`.
- Use a `DataManager` protocol for actions involving domain data from persistence/network layers.
- Use `ScreenFactory` for screen creation and presentation flow wiring.
- Trigger navigation and modal presentation through the configured screen factory environment.

### 4.3 Shared views
- Shared views are reusable UI components.
- Shared views must stay agnostic to AppState, networking, and persistence.
- Do not attach feature `ViewModel` logic to shared views; configure shared views from screen-level views.
- Expose user interactions through callback parameters.

### 4.4 UI-related file structure
- Store each Screen in a dedicated directory under `PaymentArchiveMVVM/Screens`. 
- Name the Screen directory after the feature the Screen represents.
- Store Screen-specific handler classes in the `Helper` directory inside the Screen directory.
- Store auxiliary models for a Screen in the `Model` directory inside the Screen directory.
- Extract Screen `DataManager` protocol, Screen configuration and auxiliary models into `<FeatureName>+AddOns.swift`.
- Store each Shared view in a dedicated directory under `PaymentArchiveMVVM/Shared/View`.
- Name each Shared view directory after the view name.
- Keep view-specific extensions in the same feature directory and name them `<ViewName>+AddOns.swift`.

### 4.5 Theming and styling
- Centralize color/theme definitions in `Services/Theme`.
- Avoid hardcoded colors in feature views when theme tokens exist.
- Keep spacing, typography, and icon usage consistent across features.

### 4.6 Accessibility baseline
- Provide meaningful accessibility labels and hints for interactive controls.
- Support Dynamic Type where practical.

## 5. State, concurrency, and async rules (TBD)
- Prefer Swift Concurrency (`async/await`) over callback-heavy code.
- Keep async work cancellable and scoped to lifecycle.
- Update UI state on the main actor when required.

## 6. Data and persistence conventions (TBD)
- Keep DTO/record mapping explicit and localized.
- Avoid leaking storage-specific types into domain/UI layers.
- Use stable identifiers and deterministic ordering where needed.

## 7. Testing strategy
### 7.1 Providing testability
- Separate responsibilities and break business logic into small classes.
- Inject dependencies through initializers or function parameters to facilitate use of mocked data.

### 7.2 Unit tests
- Prefer deterministic fixtures and explicit assertions.
- Use clear behavior-based names (Given/When/Then style optional).

## 8. How to add a new feature
1. Create a screen folder under `Screens/` following the UI convention in section 4.
2. Reuse shared components before introducing new shared UI.
3. Add/update service abstractions if new business operations are required.
4. Add unit tests for logic.

## 9. Tooling and quality gates (TBD)
- Formatting:
- Linting:
- CI checks:
- Build/test commands:

## 10. Documentation map
- Root agent contract: [AGENTS.md](../AGENTS.md)
- Public project intro: [​README​.md](../​README​.md)
- Deep conventions: this file

## 11. Open decisions / TODO
- Define concrete spacing/typography scale.
- Define theme token catalog.
- Define required minimum test coverage for new features.
- Decide linting/formatting tooling and CI enforcement timeline.
