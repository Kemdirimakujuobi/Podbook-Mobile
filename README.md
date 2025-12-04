# Podbook - Podcast Player App

A SwiftUI-based podcast player app inspired by Apple Podcasts, featuring a timeline-style feed and an immersive transcript-driven playback experience.

## Features

### Feed View
- **Featured Section**: Horizontal scrollable carousel of featured podcasts with colorful album covers
- **Timeline Sections**: Organized by time periods (Today, Yesterday) with episode counts
- **Podcast Cards**: Display album art, title, author, date, duration, category, and progress
- **Episode Count Badges**: Shows number of episodes available

### Now Playing View
- **Scrolling Transcript**: Large, readable text that scrolls automatically in sync with playback
- **Active Segment Highlighting**: Current transcript segment is emphasized
- **Interactive Transcript**: Tap any segment to jump to that point in the episode
- **Playback Controls**:
  - Play/Pause button
  - Skip forward/backward 15 seconds
  - Draggable playhead for seeking
- **Progress Bar**: Shows current position in the episode
- **Gradient Background**: Dynamic color based on podcast artwork

## Project Structure

```
Podbook Mobile/
├── PodbookApp.swift              # App entry point
├── ContentView.swift              # Main tab view container
├── Models/
│   ├── Podcast.swift              # Podcast data model with sample data
│   └── Transcript.swift           # Transcript segment model
├── Views/
│   ├── FeedView.swift             # Main feed/timeline view
│   ├── NowPlayingView.swift       # Playback view with transcript
│   └── Components/
│       ├── FeaturedPodcastCard.swift  # Large featured cards
│       └── PodcastCard.swift          # Timeline episode cards
└── README.md
```

## Setup Instructions

1. **Create a new Xcode project**:
   - Open Xcode
   - File → New → Project
   - Choose "App" under iOS
   - Product Name: "Podbook"
   - Interface: SwiftUI
   - Language: Swift
   - Save to: `/Users/kemdirim/Documents/GitHub/Podbook Mobile`

2. **Add the source files**:
   - Delete the default `ContentView.swift` and App file that Xcode creates
   - Add all the `.swift` files from this directory to your project
   - Make sure to maintain the folder structure (Models, Views, Views/Components)

3. **Configure Info.plist** (if needed):
   - Set deployment target to iOS 16.0 or higher
   - Configure any required permissions

4. **Run the app**:
   - Select a simulator or device
   - Press Cmd+R to build and run

## Design Inspiration

This app is based on the Figma designs at:
- Feed View: https://www.figma.com/design/vnayZy5IpBew0VWC67w63g/Podbook?node-id=74-3415
- Now Playing: https://www.figma.com/design/vnayZy5IpBew0VWC67w63g/Podbook?node-id=74-4068

Primary inspiration: Apple Podcasts app with additional influences from Spotify and Anchor for the transcript-driven playback experience.

## Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Combine**: For reactive state management
- **ScrollViewReader**: For automatic transcript scrolling
- **GeometryReader**: For custom playhead slider

## Customization

### Colors
Podcast colors are defined in the data models using string identifiers:
- "purple" → Light purple
- "pink" → Coral pink
- "yellow" → Golden yellow

### Sample Data
Edit `Podcast.swift` to add more sample episodes or modify existing ones.

### Transcript
Edit `Transcript.swift` to update the sample transcript segments.

## Future Enhancements

- [ ] Audio playback integration (AVFoundation)
- [ ] Real-time transcript synchronization
- [ ] Podcast feed fetching (RSS)
- [ ] Offline playback
- [ ] Search functionality
- [ ] User library management
- [ ] Playback speed controls
- [ ] Sleep timer
- [ ] Chapter markers
- [ ] Show notes display
