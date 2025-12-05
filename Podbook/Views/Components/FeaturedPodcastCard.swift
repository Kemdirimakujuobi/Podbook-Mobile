import SwiftUI

struct FeaturedPodcastCard: View {
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
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardColor)
                    .frame(width: 240, height: 240)

                // Duration badge
                HStack(spacing: 4) {
                    Image(systemName: "headphones")
                        .font(.system(size: 12))
                    Text(episode.formattedDuration)
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
                .padding(12)
            }
        }
    }
}

#Preview {
    FeaturedPodcastCard(episode: Episode.featuredEpisodes[0])
        .background(Color.black)
}
