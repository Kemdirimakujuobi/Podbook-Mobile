# Podbook Project Structure

Your project is now properly organized and ready to open in Xcode!

## Directory Structure

```
Podbook Mobile/
├── Podbook.xcodeproj/              # Xcode project file - DOUBLE CLICK THIS TO OPEN
│   ├── project.pbxproj
│   ├── project.xcworkspace/
│   │   └── contents.xcworkspacedata
│   └── xcshareddata/
│       └── xcschemes/
│           └── Podbook.xcscheme
│
├── Podbook/                         # Main app source directory
│   ├── PodbookApp.swift            # App entry point (@main)
│   ├── ContentView.swift           # Root tab view
│   │
│   ├── Models/                     # Data models
│   │   ├── Podcast.swift          # Podcast & PodcastSection models + sample data
│   │   └── Transcript.swift       # TranscriptSegment model + sample transcript
│   │
│   ├── Views/                      # UI views
│   │   ├── FeedView.swift         # Main feed/timeline screen
│   │   ├── NowPlayingView.swift   # Playback screen with transcript
│   │   └── Components/            # Reusable UI components
│   │       ├── FeaturedPodcastCard.swift
│   │       └── PodcastCard.swift
│   │
│   ├── Assets.xcassets/            # App assets
│   │   ├── AppIcon.appiconset/
│   │   ├── AccentColor.colorset/
│   │   └── Contents.json
│   │
│   └── Preview Content/            # SwiftUI preview assets
│       └── Preview Assets.xcassets/
│
├── README.md                        # Project documentation
├── SETUP.md                         # Setup instructions
└── PROJECT_STRUCTURE.md            # This file
```

## How to Open in Xcode

### Method 1: Finder (Easiest)
1. Open Finder
2. Navigate to: `/Users/kemdirim/Documents/GitHub/Podbook Mobile`
3. **Double-click `Podbook.xcodeproj`**
4. Xcode will open with your project ready to go

### Method 2: Command Line
```bash
cd "/Users/kemdirim/Documents/GitHub/Podbook Mobile"
open Podbook.xcodeproj
```

### Method 3: Within Xcode
1. Open Xcode
2. File → Open
3. Navigate to `/Users/kemdirim/Documents/GitHub/Podbook Mobile`
4. Select `Podbook.xcodeproj`
5. Click Open

## Quick Start

1. **Open the project** (see above)
2. **Select a simulator**: iPhone 15 Pro (recommended) from the device menu
3. **Build and run**: Press `Cmd + R` or click the Play button
4. The app will launch in the simulator

## Project Configuration

- **Deployment Target**: iOS 17.0
- **Language**: Swift 5.0
- **Framework**: SwiftUI
- **Bundle ID**: com.podbook.app
- **Supported Platforms**: iPhone only (portrait orientation)

## What You'll See

When you run the app, you'll see:

1. **Feed Tab** (default):
   - Featured podcast carousel at the top
   - "Today" section with 3 podcast episodes
   - Each card shows album art, title, metadata, and progress

2. **Tap any podcast** to open the Now Playing view:
   - Scrolling transcript that syncs with playback
   - Draggable playhead
   - Play/Pause button
   - ±15 second skip buttons

## Files Overview

### Core App
- **PodbookApp.swift**: Main app struct with `@main` entry point
- **ContentView.swift**: Tab bar with Feed and Menu tabs

### Data Layer
- **Podcast.swift**:
  - `Podcast` struct (id, title, author, date, duration, etc.)
  - `PodcastSection` struct (Today, Yesterday sections)
  - Sample data for testing

- **Transcript.swift**:
  - `TranscriptSegment` struct (startTime, endTime, text)
  - Sample transcript for demo

### UI Layer
- **FeedView.swift**: Main timeline/feed screen
- **NowPlayingView.swift**: Full-screen playback with transcript
- **FeaturedPodcastCard.swift**: Large 240x240 featured cards
- **PodcastCard.swift**: Episode cards with metadata

## Next Steps

After opening in Xcode:

1. ✅ Explore the code in Xcode
2. ✅ Run the app in simulator (`Cmd + R`)
3. ✅ Test the UI interactions
4. 🔄 Customize colors/data in `Podcast.swift`
5. 🔄 Add real audio playback (AVFoundation)
6. 🔄 Integrate podcast RSS feeds
7. 🔄 Add data persistence

## Troubleshooting

### "No scheme" error
- Make sure you're opening `Podbook.xcodeproj`, not the `Podbook` folder
- The scheme should automatically be created (Podbook scheme)

### "Cannot find type" errors
- Clean build folder: `Cmd + Shift + K`
- Rebuild: `Cmd + B`

### Preview crashes
- Make sure simulator is iOS 17.0+
- Try restarting Xcode

## Need Help?

- See [SETUP.md](SETUP.md) for detailed setup instructions
- See [README.md](README.md) for feature documentation
- Check your project in Xcode's Project Navigator (left sidebar)

---

**Ready to go!** Just double-click `Podbook.xcodeproj` to get started.
