import Foundation

struct WordTimestamp: Codable, Equatable {
    let word: String
    let startTime: TimeInterval
    let endTime: TimeInterval

    enum CodingKeys: String, CodingKey {
        case word
        case startTime = "start_time"
        case endTime = "end_time"
    }
}

struct TranscriptSegment: Identifiable {
    let id = UUID()
    let startTime: Double // in seconds
    let endTime: Double
    let text: String
    let words: [WordTimestamp] // word-level timing for future use
}

// MARK: - Sample Data for Previews
extension WordTimestamp {
    static let sampleTranscript: [WordTimestamp] = {
        let text = """
        Discover the secrets beneath our feet in Terra Firma Tales. We explore the vital role of soil in our ecosystem, from supporting plant life to filtering water. Join us as we uncover the hidden world below and learn how to protect this precious resource. The health of our soil directly impacts the food we eat and the air we breathe. In this episode, we speak with leading soil scientists about the fascinating microbiomes that exist in healthy soil and how modern agricultural practices are affecting these delicate ecosystems. We'll also explore innovative solutions for soil conservation and regenerative farming techniques that are helping to restore degraded land.
        """
        let words = text.split(separator: " ").map(String.init)
        let avgWordDuration = 0.4 // seconds per word

        return words.enumerated().map { index, word in
            let start = Double(index) * avgWordDuration
            let end = start + avgWordDuration
            return WordTimestamp(word: word, startTime: start, endTime: end)
        }
    }()
}

extension TranscriptSegment {
    // Helper function to generate word timestamps for sample data
    private static func generateWordTimestamps(text: String, startTime: Double, endTime: Double) -> [WordTimestamp] {
        let words = text.split(separator: " ").map(String.init)
        let duration = endTime - startTime
        let timePerWord = duration / Double(words.count)

        return words.enumerated().map { index, word in
            let wordStart = startTime + (Double(index) * timePerWord)
            let wordEnd = wordStart + timePerWord
            return WordTimestamp(word: word, startTime: wordStart, endTime: wordEnd)
        }
    }

    static let sampleTranscript: [TranscriptSegment] = [
        TranscriptSegment(
            startTime: 0,
            endTime: 8,
            text: "Discover the secrets beneath our feet in 'Terra Firma Tales.' We explore the vital role of soil in our ecosystem, from supporting",
            words: generateWordTimestamps(text: "Discover the secrets beneath our feet in 'Terra Firma Tales.' We explore the vital role of soil in our ecosystem, from supporting", startTime: 0, endTime: 8)
        ),
        TranscriptSegment(
            startTime: 8,
            endTime: 15,
            text: "plant life to filtering water. Join us as we uncover the hidden world below and learn how to protect this precious resource.",
            words: generateWordTimestamps(text: "plant life to filtering water. Join us as we uncover the hidden world below and learn how to protect this precious resource.", startTime: 8, endTime: 15)
        ),
        TranscriptSegment(
            startTime: 15,
            endTime: 22,
            text: "The health of our soil directly impacts the food we eat and the air we breathe. In this episode, we speak with leading soil scientists",
            words: generateWordTimestamps(text: "The health of our soil directly impacts the food we eat and the air we breathe. In this episode, we speak with leading soil scientists", startTime: 15, endTime: 22)
        ),
        TranscriptSegment(
            startTime: 22,
            endTime: 28,
            text: "about the fascinating microbiomes that exist in healthy soil and how modern agricultural practices are affecting these delicate ecosystems.",
            words: generateWordTimestamps(text: "about the fascinating microbiomes that exist in healthy soil and how modern agricultural practices are affecting these delicate ecosystems.", startTime: 22, endTime: 28)
        ),
        TranscriptSegment(
            startTime: 28,
            endTime: 35,
            text: "We'll also explore innovative solutions for soil conservation and regenerative farming techniques that are helping to restore degraded land.",
            words: generateWordTimestamps(text: "We'll also explore innovative solutions for soil conservation and regenerative farming techniques that are helping to restore degraded land.", startTime: 28, endTime: 35)
        ),
        TranscriptSegment(
            startTime: 35,
            endTime: 42,
            text: "From composting to crop rotation, discover the simple yet powerful ways we can all contribute to healthier soil and a more sustainable future.",
            words: generateWordTimestamps(text: "From composting to crop rotation, discover the simple yet powerful ways we can all contribute to healthier soil and a more sustainable future.", startTime: 35, endTime: 42)
        ),
        TranscriptSegment(
            startTime: 42,
            endTime: 48,
            text: "Stay tuned as we dig deeper into the science of soil and its crucial importance to life on Earth.",
            words: generateWordTimestamps(text: "Stay tuned as we dig deeper into the science of soil and its crucial importance to life on Earth.", startTime: 42, endTime: 48)
        )
    ]
}
