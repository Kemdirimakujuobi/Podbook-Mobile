import AVFoundation
import Combine

/// Represents the current playback phase
enum PlaybackPhase: String {
    case intro = "Intro"
    case main = "Episode"
    case outro = "Outro"
}

@MainActor
class AudioPlayerService: ObservableObject {
    static let shared = AudioPlayerService()

    // MARK: - Published Properties

    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var currentPhase: PlaybackPhase = .main

    /// The total time across all phases (intro + main + outro)
    @Published private(set) var totalDuration: TimeInterval = 0

    /// The combined current time position across all phases
    @Published private(set) var combinedCurrentTime: TimeInterval = 0

    // MARK: - Private Properties

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var durationObserver: NSKeyValueObservation?
    private var endObserver: NSObjectProtocol?

    private var currentEpisodeId: String?
    private var currentEpisode: Episode?

    // Phase durations
    private var introDuration: TimeInterval = 0
    private var mainDuration: TimeInterval = 0
    private var outroDuration: TimeInterval = 0

    // MARK: - Initialization

    private init() {
        setupAudioSession()
    }

    // MARK: - Public Methods

    /// Load an episode for playback (supports intro/main/outro phases)
    func load(episode: Episode) async {
        // Don't reload if same episode AND player exists
        // If player is nil (e.g., after app restart), we need to reload
        guard currentEpisodeId != episode.id || player == nil else { return }

        isLoading = true
        error = nil
        currentEpisodeId = episode.id
        currentEpisode = episode

        // Reset state
        stop()

        // Calculate phase durations
        introDuration = TimeInterval(episode.introDurationSeconds ?? 0)
        mainDuration = TimeInterval(episode.durationSeconds)
        outroDuration = TimeInterval(episode.outroDurationSeconds ?? 0)
        totalDuration = introDuration + mainDuration + outroDuration

        // Determine starting phase
        if episode.hasIntro {
            currentPhase = .intro
            await loadPhaseAudio(phase: .intro, episode: episode)
        } else {
            currentPhase = .main
            await loadPhaseAudio(phase: .main, episode: episode)
        }

        isLoading = false
    }

    /// Load audio for a specific phase
    private func loadPhaseAudio(phase: PlaybackPhase, episode: Episode) async {
        let urlString: String?

        switch phase {
        case .intro:
            urlString = episode.introAudioUrl
        case .main:
            urlString = episode.audioUrl
        case .outro:
            urlString = episode.outroAudioUrl
        }

        guard let urlString = urlString, let url = URL(string: urlString) else {
            error = AudioPlayerError.invalidURL
            return
        }

        // Remove old observers before creating new player
        removeObservers()

        // Create player item and player
        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)

        guard let playerItem = playerItem else {
            error = AudioPlayerError.failedToCreatePlayer
            return
        }

        player = AVPlayer(playerItem: playerItem)

        // Set up observers
        setupObservers()

        // Set duration based on phase
        switch phase {
        case .intro:
            duration = introDuration
        case .main:
            duration = mainDuration
        case .outro:
            duration = outroDuration
        }

        currentPhase = phase
        updateCombinedTime()
    }

    /// Transition to the next phase after current phase ends
    private func transitionToNextPhase() {
        guard let episode = currentEpisode else { return }

        let wasPlaying = isPlaying

        switch currentPhase {
        case .intro:
            // Intro ended, go to main
            currentPhase = .main
            Task {
                await loadPhaseAudio(phase: .main, episode: episode)
                if wasPlaying { play() }
            }

        case .main:
            // Main ended, check for outro
            if episode.hasOutro {
                currentPhase = .outro
                Task {
                    await loadPhaseAudio(phase: .outro, episode: episode)
                    if wasPlaying { play() }
                }
            } else {
                // No outro, playback complete
                isPlaying = false
                currentTime = 0
                combinedCurrentTime = 0
            }

        case .outro:
            // Outro ended, playback complete
            isPlaying = false
            currentTime = 0
            combinedCurrentTime = 0
        }
    }

    /// Update the combined time based on current phase and time
    private func updateCombinedTime() {
        switch currentPhase {
        case .intro:
            combinedCurrentTime = currentTime
        case .main:
            combinedCurrentTime = introDuration + currentTime
        case .outro:
            combinedCurrentTime = introDuration + mainDuration + currentTime
        }
    }

    /// Play or resume playback
    func play() {
        guard let player = player else { return }
        player.play()
        isPlaying = true
    }

    /// Pause playback
    func pause() {
        player?.pause()
        isPlaying = false
    }

    /// Toggle play/pause
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    /// Seek to a specific time within the current phase
    func seek(to time: TimeInterval) {
        guard let player = player else { return }

        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = time
        updateCombinedTime()
    }

    /// Seek to a combined time position (across all phases)
    func seekCombined(to combinedTime: TimeInterval) {
        guard let episode = currentEpisode else { return }

        // Determine which phase this time falls into
        if combinedTime < introDuration && episode.hasIntro {
            // Seek within intro
            if currentPhase != .intro {
                Task {
                    await loadPhaseAudio(phase: .intro, episode: episode)
                    seek(to: combinedTime)
                    if isPlaying { play() }
                }
            } else {
                seek(to: combinedTime)
            }
        } else if combinedTime < introDuration + mainDuration {
            // Seek within main episode
            let mainTime = combinedTime - introDuration
            if currentPhase != .main {
                Task {
                    await loadPhaseAudio(phase: .main, episode: episode)
                    seek(to: mainTime)
                    if isPlaying { play() }
                }
            } else {
                seek(to: mainTime)
            }
        } else if episode.hasOutro {
            // Seek within outro
            let outroTime = combinedTime - introDuration - mainDuration
            if currentPhase != .outro {
                Task {
                    await loadPhaseAudio(phase: .outro, episode: episode)
                    seek(to: outroTime)
                    if isPlaying { play() }
                }
            } else {
                seek(to: outroTime)
            }
        }
    }

    /// Skip forward by seconds
    func skipForward(by seconds: TimeInterval = 15) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }

    /// Skip backward by seconds
    func skipBackward(by seconds: TimeInterval = 15) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }

    /// Stop playback and reset
    func stop() {
        removeObservers()
        player?.pause()
        player = nil
        playerItem = nil
        isPlaying = false
        currentTime = 0
        combinedCurrentTime = 0
        currentPhase = .main
    }

    /// Switch to a new audio URL and resume at a specific time
    /// Used when a question response is stitched into the episode
    func switchAudio(to newAudioUrl: String, resumeAt timestamp: TimeInterval) async {
        guard let url = URL(string: newAudioUrl) else {
            error = AudioPlayerError.invalidURL
            return
        }

        isLoading = true

        // Remove old observers
        removeObservers()

        // Create new player with the updated audio
        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)

        guard let playerItem = playerItem else {
            error = AudioPlayerError.failedToCreatePlayer
            isLoading = false
            return
        }

        player = AVPlayer(playerItem: playerItem)
        setupObservers()

        // Wait for player to be ready
        await waitForPlayerReady()

        // Seek to the resume position
        seek(to: timestamp)

        isLoading = false

        // Resume playback
        play()
    }

    /// Wait for the player to be ready to play
    private func waitForPlayerReady() async {
        guard let playerItem = playerItem else { return }

        // Check if already ready
        if playerItem.status == .readyToPlay {
            return
        }

        // Wait for status change
        await withCheckedContinuation { continuation in
            var observer: NSKeyValueObservation?
            observer = playerItem.observe(\.status, options: [.new]) { item, _ in
                if item.status == .readyToPlay || item.status == .failed {
                    observer?.invalidate()
                    continuation.resume()
                }
            }

            // Timeout after 10 seconds
            Task {
                try? await Task.sleep(nanoseconds: 10_000_000_000)
                observer?.invalidate()
                continuation.resume()
            }
        }
    }

    // MARK: - Private Methods

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [])
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func setupObservers() {
        guard let player = player, let playerItem = playerItem else { return }

        // Time observer - update every 0.1 seconds
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                guard let self = self else { return }
                self.currentTime = time.seconds
                self.updateCombinedTime()
            }
        }

        // Status observer
        statusObserver = playerItem.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self = self else { return }
                switch item.status {
                case .readyToPlay:
                    self.isLoading = false
                case .failed:
                    self.error = item.error ?? AudioPlayerError.playbackFailed
                    self.isLoading = false
                default:
                    break
                }
            }
        }

        // Duration observer
        durationObserver = playerItem.observe(\.duration, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self = self else { return }
                let seconds = item.duration.seconds
                if seconds.isFinite && seconds > 0 {
                    self.duration = seconds
                }
            }
        }

        // End of playback notification - transition to next phase
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.transitionToNextPhase()
            }
        }
    }

    private func removeObservers() {
        if let timeObserver = timeObserver, let player = player {
            player.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
        statusObserver?.invalidate()
        statusObserver = nil
        durationObserver?.invalidate()
        durationObserver = nil

        if let endObserver = endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = nil
    }
}

// MARK: - Error Types

enum AudioPlayerError: Error, LocalizedError {
    case invalidURL
    case failedToCreatePlayer
    case playbackFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid audio URL"
        case .failedToCreatePlayer:
            return "Failed to create audio player"
        case .playbackFailed:
            return "Playback failed"
        }
    }
}
