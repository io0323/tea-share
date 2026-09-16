import Foundation
import SwiftData
import OSLog

/*
 プレビュー・開発用のModelContainerを提供するヘルパーです。
 */
enum PreviewContainer {
  private static let logger = Logger(subsystem: "com.teashare.app", category: "PreviewContainer")

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
      Self.logger.info("PreviewContainer initialized successfully with sample data")
      return container
    } catch {
      Self.logger.error("PreviewContainer initialization failed: \(error.localizedDescription)")
      fatalError("PreviewContainer initialization failed: \(error.localizedDescription)")
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
        remainingGrams: AppConstants.PreviewUI.sampleTeaRemainingGrams[0],
        expiryDate: Calendar.current.date(byAdding: .month, value: AppConstants.PreviewUI.sampleTeaExpiryMonths[0], to: now)
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
        remainingGrams: AppConstants.PreviewUI.sampleTeaRemainingGrams[1],
        expiryDate: Calendar.current.date(byAdding: .month, value: AppConstants.PreviewUI.sampleTeaExpiryMonths[1], to: now)
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
        remainingGrams: AppConstants.PreviewUI.sampleTeaRemainingGrams[2],
        expiryDate: Calendar.current.date(byAdding: .month, value: AppConstants.PreviewUI.sampleTeaExpiryMonths[2], to: now)
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
        remainingGrams: AppConstants.PreviewUI.sampleTeaRemainingGrams[3],
        expiryDate: Calendar.current.date(byAdding: .month, value: AppConstants.PreviewUI.sampleTeaExpiryMonths[3], to: now)
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
    let currentCount: Int
    do {
      currentCount = try context.fetchCount(descriptor)
    } catch {
      Self.logger.error("Failed to fetch tea leaf count: \(error.localizedDescription)")
      currentCount = 0
    }
    
    guard currentCount == 0 else {
      Self.logger.debug("Sample data already exists (\(currentCount) tea leaves)")
      return
    }

    Self.logger.info("Inserting sample data into preview container")
    let owners = sampleUsers
    owners.forEach { context.insert($0) }

    let teas = sampleTeaLeaves
    teas.forEach { context.insert($0) }

    let tradeIndex = AppConstants.PreviewUI.sampleTradeTeaIndex
    let requesterIndex = AppConstants.PreviewUI.sampleTradeRequesterIndex
    let ownerIndex = AppConstants.PreviewUI.sampleTradeOwnerIndex
    
    if teas.count > tradeIndex && owners.count > max(requesterIndex, ownerIndex) {
      let trade = Trade(
        teaLeaf: teas[tradeIndex],
        requester: owners[requesterIndex],
        owner: owners[ownerIndex],
        status: .pending
      )
      context.insert(trade)
    }
    Self.logger.info("Sample data insertion completed")
  }

  /*
   東京駅近辺にランダムな座標を生成します。
   */
  private static func randomCoordinate() -> (
    latitude: Double,
    longitude: Double
  ) {
    let latitude = 35.681236 + Double.random(in: AppConstants.PreviewUI.coordinateRange)
    let longitude = 139.767125 + Double.random(in: AppConstants.PreviewUI.coordinateRange)
    return (latitude, longitude)
  }
}
