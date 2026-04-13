# AGENTS.md

This file defines the default behavior contract for AI coding agents working in this repository.

## Scope and priority
- Treat this file as repository-wide guidance unless a deeper `AGENTS.md` overrides it.
- Follow explicit user instructions first.
- Keep changes limited to the requested task.

## Project orientation
- Read [Project Guide](Docs/ProjectGuide.md) before making any changes and obey the related guidelines.
- Preserve the existing architecture and file and module structure.
- Prefer extending existing components over creating parallel patterns.

## Core engineering rules
- Make minimal, focused edits.
- Avoid unrelated refactors.
- Prefer readable, explicit code over clever code.
- Never force-unwrap unless there is a documented invariant.
- Conform to concurrency and async rules defined in [Project Guide](Docs/ProjectGuide.md).

## Swift / SwiftUI conventions
- Follow general Swift guidelines for function, property, class, and unit test naming.
- Follow general Swift guidelines for formatting.
- Conform to high-level architecture patterns defined in [Project Guide](Docs/ProjectGuide.md).
- Favor value semantics and immutability where practical.

## File and module conventions
- Follow existing folder structure and file naming patterns.

## Testing expectations
- Add or update tests when behavior changes.
- Prefer deterministic tests over time-dependent or flaky assertions.
- Keep unit tests near existing test style and naming conventions.
- Prefer the Testing framework over XCTest.

## Validation checklist
Before finalizing:
1. Build or run relevant checks for touched code.
2. Confirm no unrelated files were modified.
3. Summarize what changed and any remaining risks.

## Collaboration expectations
- State assumptions when requirements are ambiguous.
- If blocked, explain the blocker and propose the smallest viable next step.
- Prefer concrete tradeoffs over generic advice.
