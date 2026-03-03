import Foundation
import SwiftData

/*
 プレビュー・開発用のModelContainerを提供するヘルパーです。
 */
enum PreviewContainer {
  /*
   サンプルデータを投入済みのModelContainerを返します。
   */
  static var shared: ModelContainer = {
    let schema = Schema([TeaLeaf.self, User.self, Trade.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

    do {
      let container = try ModelContainer(
        for: schema,
        configurations: [configuration]
      )
      insertSampleDataIfNeeded(context: container.mainContext)
      return container
    } catch {
      fatalError("PreviewContainer initialization failed: \(error)")
    }
  }()

  /*
   画面プレビュー向けの茶葉サンプルを返します。
   */
  static var sampleTeaLeaves: [TeaLeaf] {
    let owners = sampleUsers
    let now = Date()
    let c1 = randomCoordinate()
    let c2 = randomCoordinate()
    let c3 = randomCoordinate()
    let c4 = randomCoordinate()

    return [
      TeaLeaf(
        name: "八女煎茶",
        brand: "茶寮みどり",
        category: .greenTea,
        remainingGrams: 45,
        expiryDate: Calendar.current.date(byAdding: .month, value: 8, to: now)
          ?? now,
        description: "旨味が濃く、食後にも合う煎茶です。",
        latitude: c1.latitude,
        longitude: c1.longitude,
        tradeStatus: .available,
        owner: owners[0]
      ),
      TeaLeaf(
        name: "アッサムCTC",
        brand: "Tea Market",
        category: .blackTea,
        remainingGrams: 80,
        expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: now)
          ?? now,
        description: "ミルクティー向けのしっかりした味わい。",
        latitude: c2.latitude,
        longitude: c2.longitude,
        tradeStatus: .available,
        owner: owners[1]
      ),
      TeaLeaf(
        name: "凍頂烏龍",
        brand: "山霧茶舗",
        category: .oolongTea,
        remainingGrams: 30,
        expiryDate: Calendar.current.date(byAdding: .month, value: 10, to: now)
          ?? now,
        description: "華やかな香りと軽い甘みの烏龍茶です。",
        latitude: c3.latitude,
        longitude: c3.longitude,
        tradeStatus: .pending,
        owner: owners[2]
      ),
      TeaLeaf(
        name: "カモミールブレンド",
        brand: "Leaf Garden",
        category: .herbalTea,
        remainingGrams: 60,
        expiryDate: Calendar.current.date(byAdding: .month, value: 4, to: now)
          ?? now,
        description: "就寝前におすすめの穏やかな味わい。",
        latitude: c4.latitude,
        longitude: c4.longitude,
        tradeStatus: .available,
        owner: owners[0]
      )
    ]
  }

  /*
   画面プレビュー向けのユーザーサンプルを返します。
   */
  static var sampleUsers: [User] {
    [
      User(username: "tea_lily", location: "渋谷区"),
      User(username: "matcha_haru", location: "墨田区"),
      User(username: "oolong_sora", location: "港区")
    ]
  }

  /*
   サンプルデータが未投入のときのみコンテキストへ投入します。
   */
  private static func insertSampleDataIfNeeded(context: ModelContext) {
    let descriptor = FetchDescriptor<TeaLeaf>()
    let currentCount = (try? context.fetchCount(descriptor)) ?? 0
    guard currentCount == 0 else { return }

    let owners = sampleUsers
    owners.forEach { context.insert($0) }

    let teas = sampleTeaLeaves
    teas.forEach { context.insert($0) }

    let trade = Trade(
      teaLeaf: teas[2],
      requester: owners[0],
      owner: owners[2],
      status: .pending
    )
    context.insert(trade)
  }

  /*
   東京駅近辺にランダムな座標を生成します。
   */
  private static func randomCoordinate() -> (
    latitude: Double,
    longitude: Double
  ) {
    let latitude = 35.681236 + Double.random(in: -0.05...0.05)
    let longitude = 139.767125 + Double.random(in: -0.05...0.05)
    return (latitude, longitude)
  }
}
