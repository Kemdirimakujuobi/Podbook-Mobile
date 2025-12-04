# Podbook Setup Guide

## Quick Start

### Option 1: Create New Xcode Project (Recommended)

1. **Open Xcode** and create a new project:
   ```
   File → New → Project
   - Choose: iOS → App
   - Product Name: Podbook
   - Team: Your Team
   - Organization Identifier: com.yourname.podbook
   - Interface: SwiftUI
   - Language: Swift
   - Use Core Data: No
   - Include Tests: Optional
   ```

2. **Replace default files**:
   - Delete the default `PodbookApp.swift` and `ContentView.swift` that Xcode creates
   - In Finder, navigate to: `/Users/kemdirim/Documents/GitHub/Podbook Mobile`
   - Drag all `.swift` files into your Xcode project
   - Make sure "Copy items if needed" is checked
   - Ensure "Add to targets" includes your main app target

3. **Organize the files**:
   Create groups in Xcode to match this structure:
   ```
   Podbook/
   ├── PodbookApp.swift
   ├── ContentView.swift
   ├── Models/
   │   ├── Podcast.swift
   │   └── Transcript.swift
   └── Views/
       ├── FeedView.swift
       ├── NowPlayingView.swift
       └── Components/
           ├── FeaturedPodcastCard.swift
           └── PodcastCard.swift
   ```

4. **Configure project settings**:
   - Select your project in the navigator
   - Under "Deployment Info":
     - iOS Deployment Target: 16.0 or higher
   - Under "Signing & Capabilities":
     - Select your development team

5. **Build and run**:
   - Select a simulator (iPhone 15 Pro recommended)
   - Press `Cmd + R` or click the Play button

### Option 2: Manual File Addition

If you already have an Xcode project:

1. Right-click on your project in Xcode
2. Select "Add Files to [Project Name]"
3. Navigate to `/Users/kemdirim/Documents/GitHub/Podbook Mobile`
4. Select all `.swift` files
5. Check "Copy items if needed"
6. Click "Add"

## File Overview

### Core App Files
- **PodbookApp.swift**: App entry point with WindowGroup
- **ContentView.swift**: Main tab bar container

### Models (Data Layer)
- **Podcast.swift**:
  - `Podcast` struct: Episode data model
  - `PodcastSection` struct: Timeline sections (Today, Yesterday)
  - Sample data for testing
- **Transcript.swift**:
  - `TranscriptSegment` struct: Timed transcript segments
  - Sample transcript for demo

### Views (UI Layer)
- **FeedView.swift**:
  - Main timeline/feed screen
  - Featured carousel
  - Sectioned episode list
- **NowPlayingView.swift**:
  - Full-screen playback view
  - Scrolling transcript
  - Playback controls
  - Progress slider

### Components (Reusable UI)
- **FeaturedPodcastCard.swift**: Large card for featured section
- **PodcastCard.swift**: Episode card for timeline list

## Requirements

- **Xcode**: 15.0 or later
- **iOS Deployment Target**: 16.0 or later
- **Swift**: 5.9 or later
- **Platform**: iOS

## Common Issues

### "Cannot find type in scope" errors
- Make sure all files are added to your target
- Check that file names match exactly
- Verify the folder structure is correct

### Preview crashes
- Make sure you're using iOS 16.0+ simulator
- Try cleaning build folder: `Cmd + Shift + K`
- Restart Xcode

### Dark mode issues
- The app is designed for dark mode
- If testing in light mode, colors may need adjustment

## Testing the App

1. **Feed View**:
   - Scroll through featured podcasts horizontally
   - Tap any podcast card to open playback view
   - Observe episode metadata (duration, category, progress)

2. **Now Playing View**:
   - Drag the playhead to seek
   - Tap play/pause to toggle playback state
   - Tap 15-second skip buttons
   - Tap transcript lines to jump to that segment
   - Swipe down or tap back button to dismiss

## Next Steps

After basic setup:

1. **Integrate AVFoundation** for real audio playback
2. **Add networking** to fetch real podcast feeds
3. **Implement persistence** with Core Data or SwiftData
4. **Add search** functionality
5. **Implement downloads** for offline playback
6. **Add user preferences** (playback speed, sleep timer)

## Need Help?

Check the main [README.md](README.md) for more details about the app architecture and features.
