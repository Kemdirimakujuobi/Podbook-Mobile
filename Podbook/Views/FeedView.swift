import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var presentedEpisode: Episode?
    @State private var showAddEpisode = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Featured Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Featured")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                Spacer()

                                Button(action: { showAddEpisode = true }) {
                                    Image(systemName: "plus")
                                        .font(.title3)
                                        .foregroundColor(.white.opacity(0.8))
                                        .frame(width: 36, height: 36)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.featuredEpisodes) { episode in
                                        FeaturedPodcastCard(episode: episode)
                                            .onTapGesture {
                                                presentedEpisode = episode
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
                                                presentedEpisode = episode
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
        .fullScreenCover(item: $presentedEpisode) { episode in
            NowPlayingView(episode: episode, presentedEpisode: $presentedEpisode)
        }
        .sheet(isPresented: $showAddEpisode) {
            AddEpisodeSheet(isPresented: $showAddEpisode)
                .presentationDetents([.medium, .large])
        }
        .task {
            await viewModel.loadEpisodes()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.episodeGenerated)) { _ in
            Task {
                await viewModel.refresh()
            }
        }
    }
}

#Preview {
    FeedView()
}
