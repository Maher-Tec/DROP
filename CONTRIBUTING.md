# Contributing to DROP

Thanks for your interest in contributing! DROP is intentionally small and private — please keep that spirit in mind.

## Ground rules

- No analytics, telemetry, or network calls. DROP saves and sends nothing.
- No new persisted data beyond preferences and onboarding state.
- Keep the UI calm and distraction-free; avoid adding streaks, counters, or gamification.

## Workflow

1. Fork the repo and create a branch from `main`.
2. Make your changes.
3. Run checks before opening a PR:
   ```sh
   flutter analyze
   flutter test
   ```
4. Open a pull request describing what changed and why.

For anything beyond a small fix (new screens, new dependencies, behavior changes), please open an issue first to discuss the approach before writing code.

## Reporting bugs

Open a GitHub issue with steps to reproduce, your platform (Android/iOS) and OS version, and the app version from `pubspec.yaml`.
