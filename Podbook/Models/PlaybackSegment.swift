import Foundation

struct PlaybackSegment: Identifiable, Equatable {
    let id: UUID
    let label: String
    let startTime: TimeInterval
    let endTime: TimeInterval

    var duration: TimeInterval {
        endTime - startTime
    }
}

extension PlaybackSegment {
    static let sampleSegments: [PlaybackSegment] = [
        PlaybackSegment(
            id: UUID(),
            label: "Intro",
            startTime: 0,
            endTime: 300  // 5 minutes
        ),
        PlaybackSegment(
            id: UUID(),
            label: "Main Content",
            startTime: 300,
            endTime: 2700  // 40 minutes
        ),
        PlaybackSegment(
            id: UUID(),
            label: "Discussion",
            startTime: 2700,
            endTime: 3000  // 5 minutes
        ),
        PlaybackSegment(
            id: UUID(),
            label: "Outro",
            startTime: 3000,
            endTime: 3274  // ~4.5 minutes
        )
    ]
}
