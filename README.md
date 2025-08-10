# Interval Trainer

An iOS 17+ SwiftUI application for interval training with precise timing and background state management.

## Features

### Timer Management
- Create timers with 1-6 intervals each
- Each interval has a name and duration (1 second to 10 minutes)
- Mark timers as favorites for quick access
- Duplicate existing timers
- Drag-and-drop reordering of intervals

### Timer Execution
- Start, pause, resume, reset functionality
- Skip to next/previous intervals
- Restart current interval
- Loop mode for continuous cycling
- Accurate timing with ContinuousClock
- Background state preservation and restoration

### Feedback
- Haptic feedback: rigid impulse for interval end, success for cycle end
- Audio feedback: system sounds for interval and cycle completion
- Visual feedback: progress bars and countdown display

### Settings
- Loop enabled/disabled
- Haptic feedback on/off
- Audio feedback on/off  
- Time format: seconds only (125) or minutes:seconds (2:05)

## Architecture

### MVVM with Observation
- `@Observable` ViewModels (iOS 17+ pattern)
- No legacy `ObservableObject` usage
- Clean separation of concerns

### Repository Pattern
- `TimersRepository` protocol for abstraction
- `TimersRepositorySwiftData` implementation
- SwiftData model management encapsulated

### Service Layer
- `AudioService` for sound feedback
- `HapticsService` for tactile feedback
- Protocol-based design for testability

### Data Models
- `TimerTemplate`: Main timer entity with intervals
- `IntervalItem`: Individual interval with name, duration, order
- SwiftData `@Model` annotations for persistence

### Timing Logic
- Reference-based time calculation using `Date` and `Duration`
- Background/foreground state handling
- Precise elapsed time computation for accurate countdown

## Background Handling

When the app goes to background during timer execution:
1. Current state saved (interval, remaining time, cycle, reference timestamps)
2. On return to foreground, elapsed time calculated
3. Timer state updated (may skip multiple intervals/cycles)
4. Proper audio/haptic feedback for any completed intervals

## Testing

Comprehensive unit test coverage:
- Timer state calculations for various scenarios
- Repository CRUD operations and reordering
- Input validation logic
- Service mocking for audio/haptics

## Project Structure

```
GustavTimer/
├── Models/
│   ├── TimerTemplate.swift
│   └── IntervalItem.swift
├── Repository/
│   ├── TimersRepository.swift
│   └── TimersRepositorySwiftData.swift
├── Services/
│   ├── AudioService.swift
│   └── HapticsService.swift
├── ViewModels/
│   └── TimerViewModel.swift
├── Views/
│   ├── HomeView.swift
│   ├── TimersListView.swift
│   ├── TimerDetailView.swift
│   └── SettingsView.swift
├── Helpers/
│   ├── ValidationHelpers.swift
│   └── Extensions.swift
└── Tests/
    ├── TimerCalculationTests.swift
    ├── RepositoryTests.swift
    ├── ValidationTests.swift
    └── ServicesTests.swift
```

## Requirements

- iOS 17.0+
- iPhone only
- No third-party dependencies
- No network connectivity required
- No background tasks or notifications

## Technical Highlights

- Duration-based time management instead of simple integer seconds
- Reference timestamp approach for accuracy after background return
- Comprehensive input validation with user-friendly error messages
- Extensible service architecture with protocol abstractions
- Memory-efficient SwiftData integration with proper model relationships