import AVFoundation
import Combine

@MainActor
class AudioPlayerService: ObservableObject {
    static let shared = AudioPlayerService()

    // MARK: - Published Properties

    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    // MARK: - Private Properties

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var durationObserver: NSKeyValueObservation?

    private var currentEpisodeId: String?

    // MARK: - Initialization

    private init() {
        setupAudioSession()
    }

    // MARK: - Public Methods

    /// Load an episode for playback
    func load(episode: Episode) async {
        // Don't reload if same episode
        guard currentEpisodeId != episode.id else { return }

        isLoading = true
        error = nil
        currentEpisodeId = episode.id

        // Reset state
        stop()

        guard let url = URL(string: episode.audioUrl) else {
            error = AudioPlayerError.invalidURL
            isLoading = false
            return
        }

        // Create player item and player
        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)

        guard let playerItem = playerItem else {
            error = AudioPlayerError.failedToCreatePlayer
            isLoading = false
            return
        }

        player = AVPlayer(playerItem: playerItem)

        // Set up observers
        setupObservers()

        // Use episode duration as initial value
        duration = Double(episode.durationSeconds)

        isLoading = false
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

    /// Seek to a specific time
    func seek(to time: TimeInterval) {
        guard let player = player else { return }

        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = time
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

        // End of playback notification
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isPlaying = false
                self?.currentTime = 0
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

        NotificationCenter.default.removeObserver(self)
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
