import Foundation
import SwiftData

/*
 端末内の現在ユーザーを解決・管理するユーティリティです。
 */
enum CurrentUserManager {

  /*
   保存済み ID から現在ユーザーを取得します。
   */
  static func fetchCurrentUser(
    modelContext: ModelContext,
    storedUserId: String
  ) -> User? {
    guard !storedUserId.isEmpty,
          let id = UUID(uuidString: storedUserId) else {
      return nil
    }
    
    let targetId = id
    var descriptor = FetchDescriptor<User>(
      predicate: #Predicate<User> { user in
        user.id == targetId
      }
    )
    descriptor.fetchLimit = 1
    return try? modelContext.fetch(descriptor).first
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
      return (existing, false)
    }

    let allDescriptor = FetchDescriptor<User>()
    if let existing = try? modelContext.fetch(allDescriptor).first {
      storedUserId = existing.id.uuidString
      existing.username = username
      existing.location = location
      return (existing, false)
    }

    let user = User(username: username, location: location)
    storedUserId = user.id.uuidString
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
      return existing
    }

    let user = User(
      username: AppConstants.Defaults.State.username,
      location: AppConstants.Defaults.State.location
    )
    modelContext.insert(user)
    storedUserId = user.id.uuidString
    try? modelContext.save()
    return user
  }
}
