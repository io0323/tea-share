import SwiftUI
import SwiftData

/*
 TeaShareのルート画面です。
 */
struct ContentView: View {
  var body: some View {
    TabView {
      TeaTimelineView()
        .tabItem {
          Label("タイムライン", systemImage: "square.grid.2x2.fill")
        }

      TeaMapView()
        .tabItem {
          Label("マップ", systemImage: "map.fill")
        }

      ProfileView()
        .tabItem {
          Label("プロファイル", systemImage: "person.fill")
        }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(PreviewContainer.shared)
}
