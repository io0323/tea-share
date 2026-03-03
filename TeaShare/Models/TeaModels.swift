import Foundation
import CoreLocation
import SwiftData

/*
 TeaLeafのカテゴリを管理する列挙型です。
 */
enum TeaCategory: String, Codable, CaseIterable, Identifiable {
  case greenTea = "緑茶"
  case blackTea = "紅茶"
  case oolongTea = "烏龍茶"
  case herbalTea = "ハーブティー"
  case whiteTea = "白茶"

  var id: String { rawValue }
}

/*
 取引ステータスを管理する列挙型です。
 */
enum TradeStatus: String, Codable, CaseIterable, Identifiable {
  case available = "募集中"
  case pending = "交渉中"
  case completed = "交換完了"

  var id: String { rawValue }
}

/*
 ユーザー情報を表現するSwiftDataモデルです。
 */
@Model
final class User: Codable, Identifiable {
  @Attribute(.unique) var id: UUID
  var username: String
  var location: String

  init(
    id: UUID = UUID(),
    username: String,
    location: String
  ) {
    self.id = id
    self.username = username
    self.location = location
  }

  /*
   Codableのデコード処理を行います。
   */
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    username = try container.decode(String.self, forKey: .username)
    location = try container.decode(String.self, forKey: .location)
  }

  /*
   Codableのエンコード処理を行います。
   */
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(username, forKey: .username)
    try container.encode(location, forKey: .location)
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case username
    case location
  }
}

/*
 茶葉の出品情報を表現するSwiftDataモデルです。
 */
@Model
final class TeaLeaf: Codable, Identifiable {
  @Attribute(.unique) var id: UUID
  var name: String
  var brand: String
  var category: TeaCategory
  var remainingGrams: Int
  var expiryDate: Date
  var imagePath: String
  var description: String
  var latitude: Double
  var longitude: Double
  var tradeStatus: TradeStatus
  var owner: User?

  init(
    id: UUID = UUID(),
    name: String,
    brand: String,
    category: TeaCategory,
    remainingGrams: Int,
    expiryDate: Date,
    imagePath: String = "",
    description: String,
    latitude: Double = 35.681236,
    longitude: Double = 139.767125,
    tradeStatus: TradeStatus = .available,
    owner: User? = nil
  ) {
    self.id = id
    self.name = name
    self.brand = brand
    self.category = category
    self.remainingGrams = remainingGrams
    self.expiryDate = expiryDate
    self.imagePath = imagePath
    self.description = description
    self.latitude = latitude
    self.longitude = longitude
    self.tradeStatus = tradeStatus
    self.owner = owner
  }

  /*
   MapKit用の座標を返します。
   */
  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }

  /*
   Codableのデコード処理を行います。
   */
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    brand = try container.decode(String.self, forKey: .brand)
    category = try container.decode(TeaCategory.self, forKey: .category)
    remainingGrams = try container.decode(Int.self, forKey: .remainingGrams)
    expiryDate = try container.decode(Date.self, forKey: .expiryDate)
    imagePath = try container.decode(String.self, forKey: .imagePath)
    description = try container.decode(String.self, forKey: .description)
    latitude = try container.decode(Double.self, forKey: .latitude)
    longitude = try container.decode(Double.self, forKey: .longitude)
    tradeStatus = try container.decode(TradeStatus.self, forKey: .tradeStatus)
    owner = try container.decodeIfPresent(User.self, forKey: .owner)
  }

  /*
   Codableのエンコード処理を行います。
   */
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(name, forKey: .name)
    try container.encode(brand, forKey: .brand)
    try container.encode(category, forKey: .category)
    try container.encode(remainingGrams, forKey: .remainingGrams)
    try container.encode(expiryDate, forKey: .expiryDate)
    try container.encode(imagePath, forKey: .imagePath)
    try container.encode(description, forKey: .description)
    try container.encode(latitude, forKey: .latitude)
    try container.encode(longitude, forKey: .longitude)
    try container.encode(tradeStatus, forKey: .tradeStatus)
    try container.encode(owner, forKey: .owner)
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case brand
    case category
    case remainingGrams
    case expiryDate
    case imagePath
    case description
    case latitude
    case longitude
    case tradeStatus
    case owner
  }
}

/*
 交換リクエストを管理するSwiftDataモデルです。
 */
@Model
final class Trade: Codable, Identifiable {
  @Attribute(.unique) var id: UUID
  var teaLeaf: TeaLeaf?
  var requester: User?
  var owner: User?
  var status: TradeStatus
  var createdAt: Date

  init(
    id: UUID = UUID(),
    teaLeaf: TeaLeaf? = nil,
    requester: User? = nil,
    owner: User? = nil,
    status: TradeStatus = .pending,
    createdAt: Date = Date()
  ) {
    self.id = id
    self.teaLeaf = teaLeaf
    self.requester = requester
    self.owner = owner
    self.status = status
    self.createdAt = createdAt
  }

  /*
   Codableのデコード処理を行います。
   */
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    teaLeaf = try container.decodeIfPresent(TeaLeaf.self, forKey: .teaLeaf)
    requester = try container.decodeIfPresent(User.self, forKey: .requester)
    owner = try container.decodeIfPresent(User.self, forKey: .owner)
    status = try container.decode(TradeStatus.self, forKey: .status)
    createdAt = try container.decode(Date.self, forKey: .createdAt)
  }

  /*
   Codableのエンコード処理を行います。
   */
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(teaLeaf, forKey: .teaLeaf)
    try container.encode(requester, forKey: .requester)
    try container.encode(owner, forKey: .owner)
    try container.encode(status, forKey: .status)
    try container.encode(createdAt, forKey: .createdAt)
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case teaLeaf
    case requester
    case owner
    case status
    case createdAt
  }
}
