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
          Label(
            AppConstants.UI.Navigation.Tab.Labels.timeline,
            systemImage: AppConstants.UI.Navigation.Tab.Symbols.timeline
          )
        }

      TeaMapView()
        .tabItem {
          Label(
            AppConstants.UI.Navigation.Tab.Labels.map,
            systemImage: AppConstants.UI.Navigation.Tab.Symbols.map
          )
        }

      ProfileView()
        .tabItem {
          Label(
            AppConstants.UI.Navigation.Tab.Labels.profile,
            systemImage: AppConstants.UI.Navigation.Tab.Symbols.profile
          )
        }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(PreviewContainer.shared)
}
