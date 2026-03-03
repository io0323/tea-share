import SwiftUI
import SwiftData

/*
 TeaShareアプリのエントリポイントです。
 */
@main
struct TeaShareApp: App {
  /*
   永続化用のModelContainerを構築します。
   */
  private var sharedModelContainer: ModelContainer = {
    let schema = Schema([TeaLeaf.self, User.self, Trade.self])
    let configuration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false
    )

    do {
      return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedModelContainer)
  }
}
