import Foundation

struct Episode: Identifiable, Codable {
    let id: String
    let sourceId: String?
    let title: String
    let description: String?
    let author: String
    let category: String?
    let colorTheme: String
    let coverUrl: String?
    let audioUrl: String
    let durationSeconds: Int
    let transcript: [WordTimestamp]
    let publishedAt: Date
    let createdAt: Date

    // Computed properties for UI compatibility
    var formattedDuration: String {
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours) hr \(minutes) m"
        }
        return "\(minutes) m"
    }

    var coverColor: String { colorTheme }

    var date: Date { publishedAt }

    enum CodingKeys: String, CodingKey {
        case id
        case sourceId = "source_id"
        case title
        case description
        case author
        case category
        case colorTheme = "color_theme"
        case coverUrl = "cover_url"
        case audioUrl = "audio_url"
        case durationSeconds = "duration_seconds"
        case transcript
        case publishedAt = "published_at"
        case createdAt = "created_at"
    }
}

// MARK: - Sample Data for Previews
extension Episode {
    static let sample = Episode(
        id: "550e8400-e29b-41d4-a716-446655440000",
        sourceId: nil,
        title: "The Future of AI in Healthcare",
        description: "Exploring how artificial intelligence is transforming medical diagnosis and treatment.",
        author: "Podbook",
        category: "Technology",
        colorTheme: "purple",
        coverUrl: nil,
        audioUrl: "https://example.com/audio.mp3",
        durationSeconds: 2700,
        transcript: WordTimestamp.sampleTranscript,
        publishedAt: Date(),
        createdAt: Date()
    )

    static let sampleEpisodes: [Episode] = [
        Episode(
            id: "1",
            sourceId: nil,
            title: "Defeating Nondeterminism in LLM Inference",
            description: "A deep dive into making AI systems more predictable.",
            author: "Podbook",
            category: "Engineering",
            colorTheme: "yellow",
            coverUrl: nil,
            audioUrl: "https://example.com/audio1.mp3",
            durationSeconds: 2700,
            transcript: WordTimestamp.sampleTranscript,
            publishedAt: Date(),
            createdAt: Date()
        ),
        Episode(
            id: "2",
            sourceId: nil,
            title: "Navigating Ethical Dilemmas in AI Development",
            description: "Discussing the moral challenges facing AI researchers.",
            author: "Podbook",
            category: "Ethics",
            colorTheme: "pink",
            coverUrl: nil,
            audioUrl: "https://example.com/audio2.mp3",
            durationSeconds: 7800,
            transcript: WordTimestamp.sampleTranscript,
            publishedAt: Date(),
            createdAt: Date()
        ),
        Episode(
            id: "3",
            sourceId: nil,
            title: "Advancements in Quantum Computing for AI",
            description: "How quantum computers will accelerate machine learning.",
            author: "Podbook",
            category: "Research",
            colorTheme: "yellow",
            coverUrl: nil,
            audioUrl: "https://example.com/audio3.mp3",
            durationSeconds: 6300,
            transcript: WordTimestamp.sampleTranscript,
            publishedAt: Date(),
            createdAt: Date()
        ),
        Episode(
            id: "4",
            sourceId: nil,
            title: "Sustainable Living in Urban Spaces",
            description: "Practical tips for eco-friendly city living.",
            author: "Podbook",
            category: "Lifestyle",
            colorTheme: "green",
            coverUrl: nil,
            audioUrl: "https://example.com/audio4.mp3",
            durationSeconds: 3120,
            transcript: WordTimestamp.sampleTranscript,
            publishedAt: Date(),
            createdAt: Date()
        )
    ]

    static let featuredEpisodes: [Episode] = [
        Episode(
            id: "5",
            sourceId: nil,
            title: "The Science of Sleep",
            description: "Understanding the biology behind rest.",
            author: "Podbook",
            category: "Health",
            colorTheme: "purple",
            coverUrl: nil,
            audioUrl: "https://example.com/audio5.mp3",
            durationSeconds: 2520,
            transcript: WordTimestamp.sampleTranscript,
            publishedAt: Date(),
            createdAt: Date()
        ),
        Episode(
            id: "6",
            sourceId: nil,
            title: "Modern Love Stories",
            description: "Tales of connection in the digital age.",
            author: "Podbook",
            category: "Society",
            colorTheme: "pink",
            coverUrl: nil,
            audioUrl: "https://example.com/audio6.mp3",
            durationSeconds: 2280,
            transcript: WordTimestamp.sampleTranscript,
            publishedAt: Date(),
            createdAt: Date()
        ),
        Episode(
            id: "7",
            sourceId: nil,
            title: "Climate Action Today",
            description: "What you can do to make a difference.",
            author: "Podbook",
            category: "Environment",
            colorTheme: "yellow",
            coverUrl: nil,
            audioUrl: "https://example.com/audio7.mp3",
            durationSeconds: 3060,
            transcript: WordTimestamp.sampleTranscript,
            publishedAt: Date(),
            createdAt: Date()
        ),
        Episode(
            id: "8",
            sourceId: nil,
            title: "Urban Gardening Secrets",
            description: "Growing food in small spaces.",
            author: "Podbook",
            category: "Lifestyle",
            colorTheme: "green",
            coverUrl: nil,
            audioUrl: "https://example.com/audio8.mp3",
            durationSeconds: 1740,
            transcript: WordTimestamp.sampleTranscript,
            publishedAt: Date(),
            createdAt: Date()
        )
    ]
}
