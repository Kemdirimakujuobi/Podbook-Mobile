import SwiftUI

struct SegmentedProgressBar: View {
    @Binding var currentTime: TimeInterval
    let totalDuration: TimeInterval
    let segments: [PlaybackSegment]
    @Binding var isDragging: Bool
    let onSeek: (TimeInterval) -> Void

    private let thumbSize: CGFloat = 16
    private let segmentHeight: CGFloat = 4
    private let segmentGap: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let totalGaps = CGFloat(segments.count - 1) * segmentGap
            let totalSegmentWidth = availableWidth - totalGaps

            ZStack(alignment: .leading) {
                // Background segments (unplayed)
                HStack(spacing: segmentGap) {
                    ForEach(segments) { segment in
                        let segmentWidth = (segment.duration / totalDuration) * totalSegmentWidth

                        Capsule()
                            .fill(Color.white.opacity(0.35))
                            .frame(width: segmentWidth, height: segmentHeight)
                    }
                }

                // Progress fill (played segments)
                HStack(spacing: segmentGap) {
                    ForEach(segments) { segment in
                        let segmentWidth = (segment.duration / totalDuration) * totalSegmentWidth
                        let segmentProgress = calculateSegmentProgress(
                            segment: segment,
                            currentTime: currentTime
                        )

                        Capsule()
                            .fill(Color.white)
                            .frame(width: segmentWidth * segmentProgress, height: segmentHeight)
                            .frame(width: segmentWidth, alignment: .leading)
                    }
                }

                // Thumb (scrubber)
                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: calculateThumbPosition(
                        currentTime: currentTime,
                        totalDuration: totalDuration,
                        availableWidth: availableWidth
                    ) - thumbSize / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if !isDragging {
                                    isDragging = true
                                }
                                let newTime = calculateTimeFromPosition(
                                    position: value.location.x,
                                    availableWidth: availableWidth,
                                    totalDuration: totalDuration
                                )
                                onSeek(newTime)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            }
            .frame(height: thumbSize)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                        }
                        let newTime = calculateTimeFromPosition(
                            position: value.location.x,
                            availableWidth: availableWidth,
                            totalDuration: totalDuration
                        )
                        onSeek(newTime)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
    }

    // Calculate progress within a specific segment (0.0 to 1.0)
    private func calculateSegmentProgress(segment: PlaybackSegment, currentTime: TimeInterval) -> CGFloat {
        if currentTime <= segment.startTime {
            return 0.0
        } else if currentTime >= segment.endTime {
            return 1.0
        } else {
            let progress = (currentTime - segment.startTime) / segment.duration
            return CGFloat(progress)
        }
    }

    // Calculate thumb position including gaps
    private func calculateThumbPosition(
        currentTime: TimeInterval,
        totalDuration: TimeInterval,
        availableWidth: CGFloat
    ) -> CGFloat {
        guard totalDuration > 0 else { return 0 }

        let totalGaps = CGFloat(segments.count - 1) * segmentGap
        let totalSegmentWidth = availableWidth - totalGaps

        var accumulatedWidth: CGFloat = 0

        for (index, segment) in segments.enumerated() {
            let segmentWidth = (segment.duration / totalDuration) * totalSegmentWidth

            if currentTime <= segment.endTime {
                // Thumb is within this segment
                let timeInSegment = min(currentTime - segment.startTime, segment.duration)
                let progressInSegment = timeInSegment / segment.duration
                let positionInSegment = CGFloat(progressInSegment) * segmentWidth

                return accumulatedWidth + positionInSegment
            }

            // Add this segment's width and gap to accumulated width
            accumulatedWidth += segmentWidth
            if index < segments.count - 1 {
                accumulatedWidth += segmentGap
            }
        }

        return accumulatedWidth
    }

    // Calculate time from thumb position including gaps
    private func calculateTimeFromPosition(
        position: CGFloat,
        availableWidth: CGFloat,
        totalDuration: TimeInterval
    ) -> TimeInterval {
        let totalGaps = CGFloat(segments.count - 1) * segmentGap
        let totalSegmentWidth = availableWidth - totalGaps

        var accumulatedWidth: CGFloat = 0

        for (index, segment) in segments.enumerated() {
            let segmentWidth = (segment.duration / totalDuration) * totalSegmentWidth
            let segmentEndPosition = accumulatedWidth + segmentWidth

            if position <= segmentEndPosition {
                // Position is within this segment
                let positionInSegment = position - accumulatedWidth
                let progressInSegment = positionInSegment / segmentWidth
                let timeInSegment = Double(progressInSegment) * segment.duration

                return segment.startTime + timeInSegment
            }

            // Check if position is in the gap after this segment
            if index < segments.count - 1 {
                let gapEndPosition = segmentEndPosition + segmentGap
                if position <= gapEndPosition {
                    // Position is in the gap - return end of current segment
                    return segment.endTime
                }
                accumulatedWidth = gapEndPosition
            } else {
                accumulatedWidth = segmentEndPosition
            }
        }

        // Position is beyond all segments
        return totalDuration
    }
}
