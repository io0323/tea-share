import SwiftUI
import SwiftData
import OSLog

/*
 TeaShareアプリのエントリポイントです。
 */
@main
struct TeaShareApp: App {
  private static let logger = Logger(subsystem: "com.teashare.app", category: "TeaShareApp")

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
      let container = try ModelContainer(for: schema, configurations: [configuration])
      Self.logger.info("ModelContainer initialized successfully")
      return container
    } catch {
      Self.logger.error("Failed to create ModelContainer: \(error.localizedDescription)")
      fatalError("Could not create ModelContainer: \(error.localizedDescription)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedModelContainer)
  }
}
