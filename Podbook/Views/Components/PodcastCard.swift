import SwiftUI

struct PodcastCard: View {
    let podcast: Podcast

    var cardColor: Color {
        switch podcast.coverColor {
        case "purple": return Color(red: 0.6, green: 0.5, blue: 0.9)
        case "pink": return Color(red: 1.0, green: 0.5, blue: 0.6)
        case "yellow": return Color(red: 0.95, green: 0.8, blue: 0.2)
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

                // Episode count badge
                HStack(spacing: 4) {
                    Image(systemName: "headphones")
                        .font(.system(size: 10))
                    Text("\(podcast.episodeCount)")
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
                Text(podcast.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(podcast.author)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Text(formatDate(podcast.date))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    // Progress bar
                    if podcast.progress > 0 {
                        HStack(spacing: 0) {
                            Text("•")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 3)

                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white)
                                        .frame(width: geometry.size.width * podcast.progress, height: 3)
                                }
                            }
                            .frame(height: 3)
                            .frame(maxWidth: 60)

                            Text("•")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                    }

                    Text(podcast.duration)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(6)

                    Text(podcast.category)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(6)
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
    PodcastCard(podcast: Podcast.sampleData[0].podcasts[0])
        .background(Color.black)
}
