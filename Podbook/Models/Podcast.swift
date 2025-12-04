import Foundation

struct Podcast: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let date: Date
    let duration: String
    let category: String
    let coverColor: String
    let progress: Double // 0.0 to 1.0
    let episodeCount: Int
}

struct PodcastSection: Identifiable {
    let id = UUID()
    let title: String
    let count: Int
    let podcasts: [Podcast]
}

// Sample data
extension Podcast {
    static let sampleData: [PodcastSection] = [
        PodcastSection(
            title: "Today",
            count: 4,
            podcasts: [
                Podcast(
                    title: "Defeating Nondeterminism in LLM Inference",
                    author: "Thinking Machines",
                    date: Date(),
                    duration: "45 m",
                    category: "Engineering",
                    coverColor: "yellow",
                    progress: 0.43,
                    episodeCount: 13
                ),
                Podcast(
                    title: "Navigating Ethical Dilemmas in AI Development",
                    author: "AI Ethics Alliance",
                    date: Date(),
                    duration: "2 hr 10 m",
                    category: "Ethics",
                    coverColor: "pink",
                    progress: 0.0,
                    episodeCount: 13
                ),
                Podcast(
                    title: "Advancements in Quantum Computing for AI",
                    author: "Quantum Innovations",
                    date: Date(),
                    duration: "1 hr 45 m",
                    category: "Research",
                    coverColor: "yellow",
                    progress: 0.0,
                    episodeCount: 13
                ),
                Podcast(
                    title: "Sustainable Living in Urban Spaces",
                    author: "City Green",
                    date: Date(),
                    duration: "52 m",
                    category: "Lifestyle",
                    coverColor: "green",
                    progress: 0.67,
                    episodeCount: 21
                )
            ]
        )
    ]

    static let featuredPodcasts: [Podcast] = [
        Podcast(
            title: "The Science of Sleep",
            author: "Dream Lab",
            date: Date(),
            duration: "42 m",
            category: "Health",
            coverColor: "purple",
            progress: 0.0,
            episodeCount: 24
        ),
        Podcast(
            title: "Modern Love Stories",
            author: "Heartbeat Media",
            date: Date(),
            duration: "38 m",
            category: "Society",
            coverColor: "pink",
            progress: 0.0,
            episodeCount: 18
        ),
        Podcast(
            title: "Climate Action Today",
            author: "Earth Chronicles",
            date: Date(),
            duration: "51 m",
            category: "Environment",
            coverColor: "yellow",
            progress: 0.0,
            episodeCount: 32
        ),
        Podcast(
            title: "Urban Gardening Secrets",
            author: "Green Thumb Society",
            date: Date(),
            duration: "29 m",
            category: "Lifestyle",
            coverColor: "green",
            progress: 0.0,
            episodeCount: 16
        )
    ]
}
