import SwiftUI

struct NowPlayingView: View {
    let episode: Episode
    @Binding var presentedEpisode: Episode?

    @StateObject private var audioPlayer = AudioPlayerService.shared
    @State private var isDragging = false
    @State private var dragTime: Double = 0
    @State private var skipBackwardRotation: Double = 0
    @State private var skipForwardRotation: Double = 0
    @StateObject private var transcriptViewModel: TranscriptViewModel
    @State private var showQuestionSheet = false
    @State private var questionTimestamp: TimeInterval = 0

    /// Current time within the current phase
    var currentTime: Double {
        isDragging ? dragTime : audioPlayer.currentTime
    }

    /// Combined current time across all phases (for transcript sync)
    var combinedCurrentTime: Double {
        isDragging ? dragTime : audioPlayer.combinedCurrentTime
    }

    var currentTimeBinding: Binding<Double> {
        Binding(
            get: { combinedCurrentTime },
            set: { newValue in
                dragTime = newValue
            }
        )
    }

    /// Time relative to main episode for transcript highlighting
    /// During intro/outro, this returns 0 or max time respectively
    var transcriptTimeBinding: Binding<Double> {
        Binding(
            get: {
                let introDuration = Double(episode.introDurationSeconds ?? 0)
                switch audioPlayer.currentPhase {
                case .intro:
                    return 0 // Transcript hasn't started yet
                case .main:
                    return audioPlayer.currentTime // Direct time within main episode
                case .outro:
                    return Double(episode.durationSeconds) // Transcript is at end
                }
            },
            set: { _ in }
        )
    }

    /// Total duration across all phases
    var totalDuration: Double {
        audioPlayer.totalDuration > 0 ? audioPlayer.totalDuration : Double(episode.totalDurationSeconds)
    }

    /// Build playback segments for the progress bar
    var playbackSegments: [PlaybackSegment] {
        var segments: [PlaybackSegment] = []
        var currentStart: Double = 0

        // Intro segment
        if episode.hasIntro, let introDuration = episode.introDurationSeconds {
            segments.append(PlaybackSegment(
                id: UUID(),
                label: "Intro",
                startTime: currentStart,
                endTime: currentStart + Double(introDuration)
            ))
            currentStart += Double(introDuration)
        }

        // Main episode segment
        segments.append(PlaybackSegment(
            id: UUID(),
            label: "Episode",
            startTime: currentStart,
            endTime: currentStart + Double(episode.durationSeconds)
        ))
        currentStart += Double(episode.durationSeconds)

        // Outro segment
        if episode.hasOutro, let outroDuration = episode.outroDurationSeconds {
            segments.append(PlaybackSegment(
                id: UUID(),
                label: "Outro",
                startTime: currentStart,
                endTime: currentStart + Double(outroDuration)
            ))
        }

        return segments
    }

    init(episode: Episode, presentedEpisode: Binding<Episode?>) {
        self.episode = episode
        self._presentedEpisode = presentedEpisode

        // Convert word timestamps to transcript segments for the view model
        let segments = Self.createTranscriptSegments(from: episode.transcript)
        self._transcriptViewModel = StateObject(wrappedValue: TranscriptViewModel(segments: segments))
    }

    private static func createTranscriptSegments(from words: [WordTimestamp]) -> [TranscriptSegment] {
        guard !words.isEmpty else {
            return TranscriptSegment.sampleTranscript
        }

        // Group words into segments of ~10 words each
        let wordsPerSegment = 10
        var segments: [TranscriptSegment] = []

        for i in stride(from: 0, to: words.count, by: wordsPerSegment) {
            let endIndex = min(i + wordsPerSegment, words.count)
            let segmentWords = Array(words[i..<endIndex])

            guard let firstWord = segmentWords.first,
                  let lastWord = segmentWords.last else { continue }

            let text = segmentWords.map { $0.word }.joined(separator: " ")
            let segment = TranscriptSegment(
                startTime: firstWord.startTime,
                endTime: lastWord.endTime,
                text: text,
                words: segmentWords
            )
            segments.append(segment)
        }

        return segments.isEmpty ? TranscriptSegment.sampleTranscript : segments
    }

    var palette: ColorPalette {
        ColorPalette.palette(for: episode.coverColor)
    }

    var backgroundColor: Color {
        Color(palette: palette.shade900)
    }

    var transcriptActiveColor: Color {
        Color(palette: palette.shade300)
    }

    var transcriptInactiveColor: Color {
        Color(palette: palette.shade400)
    }

    var authorNameColor: Color {
        Color(palette: palette.shade300)
    }


    /// Gradient colors for the immersive overlay
    private var overlayGradientColors: [Color] {
        [
            Color(palette: palette.shade400),
            Color(palette: palette.shade600),
            Color(palette: palette.shade800),
            Color(palette: palette.shade900)
        ]
    }

    var body: some View {
        ImmersiveOverlayContainer(
            isPresented: $showQuestionSheet,
            colors: overlayGradientColors,
            background: {
                // Main NowPlayingView content
                nowPlayingContent
            },
            overlay: {
                // Question sheet content
                ImmersiveQuestionContent(
                    isPresented: $showQuestionSheet,
                    episode: episode,
                    timestamp: questionTimestamp,
                    transcriptContext: getTranscriptContext(),
                    onResponseReady: { newAudioUrl in
                        Task {
                            await audioPlayer.switchAudio(to: newAudioUrl, resumeAt: questionTimestamp)
                        }
                    }
                )
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .statusBarHidden(true)
        .task {
            await audioPlayer.load(episode: episode)
        }
    }

    // MARK: - Main Content

    private var nowPlayingContent: some View {
        ZStack {
            // Background
            backgroundColor
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Header VStack - spacing: 8
                VStack(alignment: .leading, spacing: 8) {
                    // Dismiss handle - 48w × 4h, 15% opacity
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 48, height: 4)
                        .frame(maxWidth: .infinity)

                    // Title + Icon lockup
                    HStack(alignment: .center) {
                        Text(episode.author ?? "Podbook")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(authorNameColor)

                        Spacer()

                        Button(action: {}) {
                            Image(systemName: "bookmark")
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.leading, 24)
                    .padding(.trailing, 8)
                    .padding(.vertical, 0)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(0)
                .frame(width: 402, alignment: .topLeading)

                // Transcript container
                ZStack {
                    VStack(alignment: .center, spacing: 8) {
                        TranscriptScrollView(
                            viewModel: transcriptViewModel,
                            currentTime: transcriptTimeBinding,
                            activeColor: transcriptActiveColor,
                            inactiveColor: transcriptInactiveColor,
                            backgroundColor: backgroundColor
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .frame(width: 402, height: 439, alignment: .center)
                    .onAppear {
                        // Set up seek callback
                        // Transcript times are relative to main episode, so we need to
                        // account for intro duration when seeking
                        transcriptViewModel.onSeek = { time in
                            let introDuration = Double(episode.introDurationSeconds ?? 0)
                            audioPlayer.seekCombined(to: introDuration + time)
                        }
                    }

                    // Gradient overlays for softer text crop
                    VStack(spacing: 0) {
                        // Top gradient
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 402, height: 56)
                                .background(
                                    LinearGradient(
                                        stops: [
                                            Gradient.Stop(color: backgroundColor, location: 0.00),
                                            Gradient.Stop(color: backgroundColor.opacity(0), location: 1.00),
                                        ],
                                        startPoint: UnitPoint(x: 0.5, y: 0),
                                        endPoint: UnitPoint(x: 0.5, y: 1)
                                    )
                                )
                        }
                        .frame(width: 402, height: 56)

                        Spacer()

                        // Bottom gradient
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 402, height: 56)
                                .background(
                                    LinearGradient(
                                        stops: [
                                            Gradient.Stop(color: backgroundColor.opacity(0), location: 0.00),
                                            Gradient.Stop(color: backgroundColor, location: 1.00),
                                        ],
                                        startPoint: UnitPoint(x: 0.5, y: 0),
                                        endPoint: UnitPoint(x: 0.5, y: 1)
                                    )
                                )
                        }
                        .frame(width: 402, height: 56)
                    }
                    .frame(width: 402, height: 439)
                    .allowsHitTesting(false)
                }

                // Main container for bottom section
                VStack(alignment: .leading, spacing: 0) {
                    // Podcast info container
                    HStack(alignment: .top, spacing: 10) {
                        // Book cover with gradient overlay
                        ZStack {
                            // Main cover container
                            HStack(alignment: .bottom, spacing: 10) {
                                // Cover art placeholder
                                Color.clear
                            }
                            .padding(.leading, 12)
                            .padding(.trailing, 10)
                            .padding(.top, 10)
                            .padding(.bottom, 12)
                            .frame(width: 46, height: 56, alignment: .bottomLeading)
                            .background(Color(palette: palette.shade300))
                            .cornerRadius(3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .inset(by: 0.5)
                                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
                            )

                            // Gradient overlay for book effect
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 46, height: 58)
                                .position(x: 23, y: 29)
                                .background(
                                    LinearGradient(
                                        stops: [
                                            Gradient.Stop(color: .white.opacity(0), location: 0.00),
                                            Gradient.Stop(color: .white.opacity(0), location: 0.83),
                                            Gradient.Stop(color: .white.opacity(0.2), location: 0.85),
                                            Gradient.Stop(color: .white.opacity(0), location: 0.93),
                                            Gradient.Stop(color: .white.opacity(0), location: 0.93),
                                            Gradient.Stop(color: .white.opacity(0.2), location: 0.95),
                                            Gradient.Stop(color: .white.opacity(0), location: 0.97),
                                            Gradient.Stop(color: .white.opacity(0), location: 1.00),
                                        ],
                                        startPoint: UnitPoint(x: 1, y: 0.63),
                                        endPoint: UnitPoint(x: 0, y: 0.63)
                                    )
                                )
                                .allowsHitTesting(false)
                        }
                        .frame(width: 46, height: 56)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(episode.title)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }

                        Spacer()
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    // Playback container
                    VStack(alignment: .leading, spacing: 8) {
                        SegmentedProgressBar(
                            currentTime: currentTimeBinding,
                            totalDuration: totalDuration,
                            segments: playbackSegments,
                            isDragging: $isDragging,
                            onSeek: { newTime in
                                audioPlayer.seekCombined(to: max(0, min(newTime, totalDuration)))
                            }
                        )
                        .frame(height: 16)

                        // Time labels with phase indicator
                        HStack {
                            HStack(spacing: 6) {
                                Text(formatTime(combinedCurrentTime))
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.7))

                                if episode.hasIntro || episode.hasOutro {
                                    Text("·")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.4))
                                    Text(audioPlayer.currentPhase.rawValue)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }

                            Spacer()

                            Text(formatTime(totalDuration))
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .frame(width: 402, alignment: .topLeading)

                    // Playback control container
                    HStack(alignment: .center, spacing: 24) {
                        // Skip backward button (no background)
                        Button(action: {
                            audioPlayer.skipBackward()
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()

                            withAnimation(.easeInOut(duration: 0.15)) {
                                skipBackwardRotation = -30
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    skipBackwardRotation = 0
                                }
                            }
                        }) {
                            Image(systemName: "gobackward.15")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 56, height: 56)
                        }
                        .rotationEffect(.degrees(skipBackwardRotation))

                        // Play/Pause button - tap to toggle, long press to ask question
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                .contentTransition(.symbolEffect(.replace))
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .offset(x: audioPlayer.isPlaying ? 0 : 2)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 12)
                        .frame(width: 82, height: 66, alignment: .center)
                        .background(.white.opacity(0.08))
                        .cornerRadius(48)
                        .onTapGesture {
                            audioPlayer.togglePlayPause()
                        }
                        .onLongPressGesture(minimumDuration: 0.5) {
                            // Haptic feedback for long press
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()

                            // Pause playback and trigger ask mode
                            audioPlayer.pause()
                            questionTimestamp = audioPlayer.combinedCurrentTime
                            showQuestionSheet = true
                        }

                        // Skip forward button (no background)
                        Button(action: {
                            audioPlayer.skipForward()
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()

                            withAnimation(.easeInOut(duration: 0.15)) {
                                skipForwardRotation = 30
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    skipForwardRotation = 0
                                }
                            }
                        }) {
                            Image(systemName: "goforward.15")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 56, height: 56)
                        }
                        .rotationEffect(.degrees(skipForwardRotation))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 0)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(0)
                .frame(width: 402, alignment: .topLeading)
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 100 {
                        presentedEpisode = nil
                    }
                }
        )
    }

    /// Get transcript context around current playback position for question context
    private func getTranscriptContext() -> String {
        let contextWindow: TimeInterval = 15  // 15 seconds before and after
        let start = max(0, questionTimestamp - contextWindow)
        let end = questionTimestamp + contextWindow

        // Filter words within the time window
        let contextWords = episode.transcript
            .filter { $0.startTime >= start && $0.startTime <= end }
            .map { $0.word }

        return contextWords.joined(separator: " ")
    }

    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct TranscriptLine: View {
    let text: String
    let isActive: Bool
    let isPast: Bool
    let activeColor: Color
    let inactiveColor: Color

    var body: some View {
        Text(text)
            .font(.system(size: 36, weight: .semibold))
            .foregroundColor(isActive ? activeColor : inactiveColor.opacity(0.2))
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .animation(.easeOut(duration: 0.2), value: isActive)
    }
}

#Preview {
    NowPlayingView(
        episode: Episode.sample,
        presentedEpisode: .constant(Episode.sample)
    )
}
