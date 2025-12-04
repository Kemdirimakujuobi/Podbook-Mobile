import SwiftUI

struct FeedView: View {
    @State private var selectedPodcast: Podcast?
    @State private var showNowPlaying = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Featured Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Featured")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(Podcast.featuredPodcasts) { podcast in
                                        FeaturedPodcastCard(podcast: podcast)
                                            .onTapGesture {
                                                selectedPodcast = podcast
                                                showNowPlaying = true
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Timeline Sections
                        ForEach(Podcast.sampleData) { section in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(section.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)

                                    Text("\(section.count)")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)

                                VStack(spacing: 16) {
                                    ForEach(section.podcasts) { podcast in
                                        PodcastCard(podcast: podcast)
                                            .onTapGesture {
                                                selectedPodcast = podcast
                                                showNowPlaying = true
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showNowPlaying) {
            if let podcast = selectedPodcast {
                let palette = ColorPalette.palette(for: podcast.coverColor)
                let bgColor = Color(palette: palette.shade900)

                NowPlayingView(podcast: podcast, isPresented: $showNowPlaying)
                    .presentationBackground(bgColor)
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled(false)
            }
        }
    }
}

#Preview {
    FeedView()
}
