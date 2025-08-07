# GustavTimer iOS App

GustavTimer is a SwiftUI-based iOS workout timer application that allows users to create custom interval timers with audio alerts and visual backgrounds. The app targets iOS 17.0+ and is built using Xcode with Swift 5.0.

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Requirements and Limitations
- **CRITICAL**: This project can ONLY be built and run on **macOS with Xcode installed**
- Requires Xcode 15.3+ (based on project settings)  
- Requires iOS 17.0+ deployment target
- **DO NOT** attempt to build on Linux/Windows - Swift compiler alone cannot build iOS apps
- **DO NOT** attempt to install Swift on non-macOS systems for this project

### Building the App on macOS
- Open the project: `open GustavTimer.xcodeproj` 
- Build the project: `⌘+B` in Xcode or `xcodebuild -scheme GustavTimer -configuration Debug`
- **NEVER CANCEL**: Build typically takes 2-5 minutes. Set timeout to 10+ minutes
- Run in simulator: `⌘+R` in Xcode or `xcodebuild -scheme GustavTimer -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15'`

### Testing the App
- **CRITICAL**: No unit test target exists in this project
- **Manual Testing Required**: Always test complete user scenarios after making changes
- **Validation Scenarios**: 
  - Create a new timer with custom intervals
  - Start/pause/reset timer functionality
  - Test sound alerts (requires audio enabled)
  - Verify background selection works
  - Test timer completion and looping behavior
  - Verify persistent storage of custom timers

### Code Structure Validation
- Always run a build after making changes: **NEVER CANCEL** - Wait full 10 minutes if needed
- Check that new Swift files are added to the Xcode project target
- Verify asset additions are properly referenced in Assets.xcassets

## Project Structure and Key Areas

### Repository Root
```
.
├── .git/
├── .gitignore
├── GustavTimer/                 # Main source code directory
├── GustavTimer.xcodeproj/       # Xcode project file
└── docs/                        # Website documentation
```

### Main Source Directory (`GustavTimer/`)
```
GustavTimer/
├── GustavTimerApp.swift         # App entry point (@main)
├── ContentView.swift            # Main UI view
├── GustavViewModel.swift        # Core business logic and state
├── AppConfig.swift              # App-wide configuration constants
├── EditSheetView.swift          # Timer editing interface
├── BGImageView.swift            # Background image component
├── WhatsNewView.swift           # What's new screen
├── Info.plist                   # iOS app configuration
├── PrivacyInfo.xcprivacy        # Privacy manifest
├── Localizable.xcstrings        # Localization strings
├── Assets.xcassets/             # App icons, images, colors
├── Models/                      # Data models
│   ├── TimerData.swift          # Timer data structure
│   ├── BGImageModel.swift       # Background image model
│   └── CustomImageModel.swift   # Custom image model
├── SubViews/                    # UI components
│   ├── UI/                      # Basic UI elements
│   ├── ProgressArrayView.swift  # Timer progress display
│   ├── ControlButtonsView.swift # Play/pause/stop buttons
│   ├── LapsView.swift           # Lap/round tracking
│   ├── SoundSelectorView.swift  # Audio theme selection
│   └── BGSelectorView.swift     # Background selection
├── Managers/
│   └── SoundManager.swift       # Audio playback management
├── Extensions/
│   ├── HideKeyboardExtension.swift
│   └── BackgroundThumbnail.swift
├── MonthlyChallenge/            # Monthly workout challenges
├── Fonts/                       # Custom MartianMono font files
├── Sound/                       # Audio files (8 total)
└── Video/                       # Exercise demonstration videos (13 total)
```

### Key Configuration Files
- `GustavTimer.xcodeproj/project.pbxproj` - Xcode project settings
- `GustavTimer.xcodeproj/xcshareddata/xcschemes/GustavTimer.xcscheme` - Build scheme
- `GustavTimer/Info.plist` - iOS app metadata and permissions
- `GustavTimer/AppConfig.swift` - Runtime configuration constants

## Common Development Tasks

### Adding New Features
- **Always check AppConfig.swift first** for relevant constants and limits
- New UI components should go in `SubViews/` directory
- Data models belong in `Models/` directory  
- **Always add new files to the Xcode target** when creating them

### Audio and Media
- Sound files are in `Sound/` directory (MP3 format)
- Video files are in `Video/` directory (MP4 format)
- Use `SoundManager.swift` for audio playback
- Audio themes: "90s", "beep", "bell", "trumpet", "game"

### Fonts and Styling
- Custom font family: MartianMono (7 variants in `Fonts/`)
- Default app font: `MartianMonoSemiCondensed-Regular`
- Counter font: `MartianMono-Bold`
- Colors defined in `AppConfig.swift` and Assets.xcassets

### State Management
- `GustavViewModel.swift` contains the main app state
- Uses `@Published` properties for SwiftUI binding
- Data persistence via `UserDefaults`
- Timer data stored as JSON in UserDefaults

### Internationalization
- Strings defined in `Localizable.xcstrings`
- Supports English (en) and Czech (cs) locales
- Use `NSLocalizedString` for new user-facing text

## Limitations on Non-macOS Platforms

**CRITICAL WARNINGS:**
- **DO NOT** attempt to build this project on Linux or Windows
- **DO NOT** install Swift compiler expecting it to work for iOS development  
- **DO NOT** try to run iOS simulators on non-macOS systems
- Code analysis and editing can be done on any platform with Swift syntax support
- Documentation and website changes (in `docs/`) can be made on any platform

## App Features and Functionality

### Core Timer Features
- Multiple custom intervals (max 5 timers, max 600 seconds each)
- Visual progress indicators with color coding
- Audio alerts at interval transitions
- Background customization with built-in images
- Always-on display support during workouts
- Loop/repeat functionality
- Persistent timer storage

### User Interface
- SwiftUI-based with custom styling
- Portrait orientation optimized
- Status bar hidden during use
- Clean, sports-themed design
- Touch-friendly controls

### Audio System  
- Multiple sound themes available
- Separate sounds for countdown and completion
- Audio session configured for background playback
- Integrates with device audio controls

**Remember**: Always validate changes through complete user scenarios - simply building is not sufficient. Test the actual timer functionality, audio playback, and user workflows to ensure your changes work correctly.