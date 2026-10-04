import SwiftUI
import SwiftData
import OSLog

/*
 ユーザーが出品した茶葉の一覧を表示するビューです。
 */
struct MyListingsView: View {
  private static let logger = Logger(subsystem: "com.teashare.app", category: "MyListingsView")
  
  @Environment(\.modelContext) private var modelContext
  @Query private var teaLeaves: [TeaLeaf]
  @AppStorage(AppConstants.Storage.currentUserIdKey)
  private var currentUserId = ""
  @State private var cachedCurrentUser: User?

  /*
   現在ユーザーが出品した茶葉のみを返します。
   */
  private var myListings: [TeaLeaf] {
    if let cached = cachedCurrentUser {
      return filterListings(for: cached)
    }
    
    guard let currentUser = CurrentUserManager.fetchCurrentUser(
      modelContext: modelContext,
      storedUserId: currentUserId
    ) else {
      Self.logger.warning("Current user not found, returning empty listings")
      return []
    }
    
    cachedCurrentUser = currentUser
    return filterListings(for: currentUser)
  }
  
  /*
   指定ユーザーの出品をフィルタリングします。
   */
  private func filterListings(for user: User) -> [TeaLeaf] {
    let listings = teaLeaves.filter { $0.owner?.id == user.id }
    Self.logger.debug("Found \(listings.count) listings for current user")
    return listings
  }

  var body: some View {
    ScrollView {
      VStack(spacing: AppConstants.UI.Layout.Spacing.card) {
        if myListings.isEmpty {
          emptyStateView
        } else {
          LazyVStack(spacing: AppConstants.UI.Layout.Spacing.card) {
            ForEach(myListings) { teaLeaf in
              NavigationLink {
                TeaLeafDetailView(teaLeaf: teaLeaf)
              } label: {
                TeaLeafCardView(tea: teaLeaf)
              }
              .buttonStyle(AppConstants.UI.ButtonStyle.plain)
            }
          }
          .padding(.horizontal, AppConstants.UI.Padding.large)
        }
      }
      .padding(.vertical, AppConstants.UI.Padding.large)
    }
    .onChange(of: currentUserId) { _, _ in
      cachedCurrentUser = nil
    }
  }

  /*
   出品がない場合の空状態ビューを返します。
   */
  private var emptyStateView: some View {
    VStack(spacing: AppConstants.UI.Layout.Spacing.emptyState) {
      Image(systemName: AppConstants.UI.UIStrings.Content.leafFill)
        .font(.system(size: AppConstants.UI.FontSizes.emptyStateIcon))
        .foregroundStyle(.secondary)
      Text(AppConstants.UI.UIStrings.Profile.MyListings.empty)
        .font(AppConstants.UI.Typography.FontScale.sectionTitle)
      Text(AppConstants.UI.UIStrings.Profile.MyListings.emptyHint)
        .font(AppConstants.UI.Typography.Font.footnote)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity)
    .padding(.vertical, AppConstants.UI.Layout.Spacing.large)
  }
}

#Preview {
  MyListingsView()
    .modelContainer(PreviewContainer.shared)
}
