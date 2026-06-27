import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem { Label("검색", systemImage: "magnifyingglass") }

            SavedVersesView()
                .tabItem { Label("저장된 말씀", systemImage: "bookmark.fill") }
        }
    }
}
