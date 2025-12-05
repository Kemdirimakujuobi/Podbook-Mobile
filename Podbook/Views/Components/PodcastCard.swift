import SwiftUI

struct PodcastCard: View {
    let episode: Episode

    var cardColor: Color {
        switch episode.coverColor {
        case "purple": return Color(red: 0.6, green: 0.5, blue: 0.9)
        case "pink": return Color(red: 1.0, green: 0.5, blue: 0.6)
        case "yellow": return Color(red: 0.95, green: 0.8, blue: 0.2)
        case "green": return Color(red: 0.4, green: 0.8, blue: 0.6)
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Album Cover
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardColor)
                    .frame(width: 120, height: 120)

                // Duration badge
                HStack(spacing: 4) {
                    Image(systemName: "headphones")
                        .font(.system(size: 10))
                    Text(episode.formattedDuration)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.6))
                .cornerRadius(6)
                .padding(8)
            }

            // Metadata
            VStack(alignment: .leading, spacing: 6) {
                Text(episode.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(episode.author)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Text(formatDate(episode.publishedAt))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    Text(episode.formattedDuration)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(6)

                    if let category = episode.category {
                        Text(category)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    PodcastCard(episode: Episode.sampleEpisodes[0])
        .background(Color.black)
}
