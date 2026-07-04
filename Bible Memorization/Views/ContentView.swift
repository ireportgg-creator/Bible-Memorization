import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            StudyModePickerView()
                .tabItem { Label("Practice", systemImage: "brain.head.profile") }

            LibraryView()
                .tabItem { Label("Library", systemImage: "books.vertical.fill") }
        }
        .tint(.terracotta)
    }
}
