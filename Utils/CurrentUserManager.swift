import Foundation
import SwiftData
import OSLog

/*
 端末内の現在ユーザーを解決・管理するユーティリティです。
 */
enum CurrentUserManager {
  private static let logger = Logger(subsystem: "com.teashare.app", category: "CurrentUserManager")

  /*
   保存済み ID から現在ユーザーを取得します。
   */
  static func fetchCurrentUser(
    modelContext: ModelContext,
    storedUserId: String
  ) -> User? {
    guard !storedUserId.isEmpty,
          let id = UUID(uuidString: storedUserId) else {
      logger.debug("Cannot fetch current user: empty or invalid stored user ID")
      return nil
    }
    
    let targetId = id
    var descriptor = FetchDescriptor<User>(
      predicate: #Predicate<User> { user in
        user.id == targetId
      }
    )
    descriptor.fetchLimit = 1
    let user = try? modelContext.fetch(descriptor).first
    
    if let user = user {
      logger.debug("Successfully fetched current user: \(user.username)")
    } else {
      logger.warning("No user found with stored ID: \(storedUserId)")
    }
    
    return user
  }

  /*
   出品時に所有者ユーザーを解決し、プロフィール情報を更新します。
   */
  static func resolveOwner(
    modelContext: ModelContext,
    storedUserId: inout String,
    username: String,
    location: String
  ) -> (user: User, isNew: Bool) {
    if let existing = fetchCurrentUser(
      modelContext: modelContext,
      storedUserId: storedUserId
    ) {
      existing.username = username
      existing.location = location
      logger.debug("Updated existing user profile: \(existing.username)")
      return (existing, false)
    }

    let allDescriptor = FetchDescriptor<User>()
    if let existing = try? modelContext.fetch(allDescriptor).first {
      storedUserId = existing.id.uuidString
      existing.username = username
      existing.location = location
      logger.debug("Updated first available user profile: \(existing.username)")
      return (existing, false)
    }

    let user = User(username: username, location: location)
    storedUserId = user.id.uuidString
    logger.info("Created new user: \(user.username)")
    return (user, true)
  }

  /*
   プロフィール画面向けに現在ユーザーを返します。
   未作成の場合はデフォルトユーザーを bootstrap します。
   */
  static func currentOrBootstrapUser(
    modelContext: ModelContext,
    storedUserId: inout String
  ) -> User? {
    if let user = fetchCurrentUser(
      modelContext: modelContext,
      storedUserId: storedUserId
    ) {
      return user
    }

    let allDescriptor = FetchDescriptor<User>()
    if let existing = try? modelContext.fetch(allDescriptor).first {
      storedUserId = existing.id.uuidString
      logger.debug("Bootstrapped to first available user: \(existing.username)")
      return existing
    }

    let user = User(
      username: AppConstants.Defaults.State.username,
      location: AppConstants.Defaults.State.location
    )
    modelContext.insert(user)
    storedUserId = user.id.uuidString
    try? modelContext.save()
    logger.info("Bootstrapped new default user: \(user.username)")
    return user
  }
}
