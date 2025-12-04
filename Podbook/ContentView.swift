import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Label("Timeline", systemImage: "square.stack")
                }
                .tag(0)

            Text("Menu")
                .tabItem {
                    Label("Menu", systemImage: "line.3.horizontal")
                }
                .tag(1)
        }
        .accentColor(.white)
    }
}

#Preview {
    ContentView()
}
