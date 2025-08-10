# Interval Trainer

Simple offline interval training app using SwiftUI, SwiftData and MVVM.

## Architecture
- **SwiftData** models `IntervalItem` and `TimerTemplate` persisted via `TimersRepository`.
- **MVVM** with `TimerViewModel` using `@Observable` from Observation framework.
- **Services** for audio and haptics injected via protocols.
- Settings stored with `@AppStorage`.

## Tests
Unit tests are provided for the timing logic and interval reordering. Run them with:

```bash
swift test
```
