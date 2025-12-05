import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var selectedEpisode: Episode?
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
                                    ForEach(viewModel.featuredEpisodes) { episode in
                                        FeaturedPodcastCard(episode: episode)
                                            .onTapGesture {
                                                selectedEpisode = episode
                                                showNowPlaying = true
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Timeline Sections
                        ForEach(viewModel.groupedEpisodes, id: \.title) { section in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(section.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)

                                    Text("\(section.episodes.count)")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)

                                VStack(spacing: 16) {
                                    ForEach(section.episodes) { episode in
                                        PodcastCard(episode: episode)
                                            .onTapGesture {
                                                selectedEpisode = episode
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
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showNowPlaying) {
            if let episode = selectedEpisode {
                let palette = ColorPalette.palette(for: episode.coverColor)
                let bgColor = Color(palette: palette.shade900)

                NowPlayingView(episode: episode, isPresented: $showNowPlaying)
                    .presentationBackground(bgColor)
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled(false)
            }
        }
        .task {
            await viewModel.loadEpisodes()
        }
    }
}

#Preview {
    FeedView()
}
