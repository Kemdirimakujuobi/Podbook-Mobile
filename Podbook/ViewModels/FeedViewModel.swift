import Foundation

@MainActor
class FeedViewModel: ObservableObject {
    @Published var episodes: [Episode] = []
    @Published var featuredEpisodes: [Episode] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let apiService = APIService.shared

    // Set to false to use real Supabase data
    private let useSampleData = false

    init() {
        if useSampleData {
            loadSampleData()
        }
    }

    // MARK: - Public Methods

    func loadEpisodes() async {
        if useSampleData {
            loadSampleData()
            return
        }

        isLoading = true
        error = nil

        do {
            let allEpisodes = try await apiService.fetchEpisodes()

            // Split into featured (first 4) and regular episodes
            if allEpisodes.count > 4 {
                featuredEpisodes = Array(allEpisodes.prefix(4))
                episodes = Array(allEpisodes.dropFirst(4))
            } else {
                featuredEpisodes = allEpisodes
                episodes = []
            }
        } catch {
            self.error = error
            // Fall back to sample data on error
            loadSampleData()
        }

        isLoading = false
    }

    func refresh() async {
        await loadEpisodes()
    }

    // MARK: - Private Methods

    private func loadSampleData() {
        featuredEpisodes = Episode.featuredEpisodes
        episodes = Episode.sampleEpisodes
    }

    // MARK: - Grouped Episodes by Date

    var groupedEpisodes: [(title: String, episodes: [Episode])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var groups: [String: [Episode]] = [:]

        for episode in episodes {
            let episodeDay = calendar.startOfDay(for: episode.publishedAt)
            let daysAgo = calendar.dateComponents([.day], from: episodeDay, to: today).day ?? 0

            let groupTitle: String
            switch daysAgo {
            case 0:
                groupTitle = "Today"
            case 1:
                groupTitle = "Yesterday"
            case 2...6:
                groupTitle = "This Week"
            default:
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                groupTitle = formatter.string(from: episode.publishedAt)
            }

            groups[groupTitle, default: []].append(episode)
        }

        // Sort groups by most recent first
        let orderedKeys = ["Today", "Yesterday", "This Week"]
        var result: [(String, [Episode])] = []

        for key in orderedKeys {
            if let episodes = groups[key] {
                result.append((key, episodes))
                groups.removeValue(forKey: key)
            }
        }

        // Add remaining month groups sorted by date
        let remainingGroups = groups.sorted { group1, group2 in
            guard let date1 = group1.value.first?.publishedAt,
                  let date2 = group2.value.first?.publishedAt else {
                return false
            }
            return date1 > date2
        }

        result.append(contentsOf: remainingGroups.map { ($0.key, $0.value) })

        return result
    }
}
