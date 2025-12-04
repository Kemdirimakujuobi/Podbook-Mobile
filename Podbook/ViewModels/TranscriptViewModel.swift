import SwiftUI
import Combine

class TranscriptViewModel: ObservableObject {
    @Published var segments: [TranscriptSegment]
    @Published var currentSegmentID: UUID?
    @Published var isUserScrolling: Bool = false
    @Published var currentTime: TimeInterval = 0

    private var springBackTimer: Timer?
    private let springBackDelay: TimeInterval = 1.5

    var onSeek: ((TimeInterval) -> Void)?

    init(segments: [TranscriptSegment]) {
        self.segments = segments
    }

    // Called by audio player on time update
    func updateTime(_ time: TimeInterval) {
        guard !isUserScrolling else { return }
        currentTime = time
        currentSegmentID = segments.first {
            time >= $0.startTime && time < $0.endTime
        }?.id
    }

    func userDidStartScrolling() {
        isUserScrolling = true
        springBackTimer?.invalidate()
    }

    func userDidEndScrolling() {
        springBackTimer?.invalidate()
        springBackTimer = Timer.scheduledTimer(withTimeInterval: springBackDelay, repeats: false) { [weak self] _ in
            self?.springBackToCurrentSegment()
        }
    }

    func userDidTapSegment(_ segment: TranscriptSegment) {
        springBackTimer?.invalidate()
        isUserScrolling = false
        currentTime = segment.startTime
        currentSegmentID = segment.id
        // Notify audio player to seek
        onSeek?(segment.startTime)
    }

    private func springBackToCurrentSegment() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isUserScrolling = false
        }
    }

    var currentSegmentIndex: Int? {
        segments.firstIndex { $0.id == currentSegmentID }
    }

    deinit {
        springBackTimer?.invalidate()
    }
}
