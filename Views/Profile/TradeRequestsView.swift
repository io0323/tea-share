import SwiftUI
import SwiftData
import OSLog

/*
 取引リクエストの一覧を表示するビューです。
 */
struct TradeRequestsView: View {
  private static let logger = Logger(subsystem: AppConstants.Logging.subsystem, category: AppConstants.Logging.Categories.tradeRequestsView)
  
  @Environment(\.modelContext) private var modelContext
  @Query private var trades: [Trade]
  @AppStorage(AppConstants.Storage.currentUserIdKey)
  private var currentUserId = ""
  @State private var selectedTab: TradeRequestTab = .incoming
  @State private var isShowingErrorAlert = AppConstants.Defaults.UI.isShowingErrorAlert
  @State private var errorMessage = AppConstants.Defaults.State.errorMessage
  @State private var cachedCurrentUser: User?

  /*
   取引リクエストのタブを管理する列挙型です。
   */
  enum TradeRequestTab: String, CaseIterable, Identifiable {
    case incoming
    case outgoing

    var id: String { rawValue }

    var displayLabel: String {
      switch self {
      case .incoming:
        return AppConstants.UI.UIStrings.Profile.TradeRequests.incoming
      case .outgoing:
        return AppConstants.UI.UIStrings.Profile.TradeRequests.outgoing
      }
    }
  }

  /*
   現在ユーザーに関連する取引リクエストを返します。
   */
  private var userTrades: [Trade] {
    if let cached = cachedCurrentUser {
      return filterTrades(for: cached)
    }
    
    guard let currentUser = CurrentUserManager.fetchCurrentUser(
      modelContext: modelContext,
      storedUserId: currentUserId
    ) else {
      Self.logger.warning("Cannot fetch user trades: current user not found")
      return []
    }
    
    cachedCurrentUser = currentUser
    return filterTrades(for: currentUser)
  }
  
  /*
   指定ユーザーの取引をフィルタリングします。
   */
  private func filterTrades(for user: User) -> [Trade] {
    let filteredTrades: [Trade]
    switch selectedTab {
    case .incoming:
      filteredTrades = trades.filter { $0.owner?.id == user.id }
    case .outgoing:
      filteredTrades = trades.filter { $0.requester?.id == user.id }
    }
    
    Self.logger.debug("Found \(filteredTrades.count) trades for \(selectedTab.displayLabel) tab")
    return filteredTrades
  }

  var body: some View {
    VStack(spacing: AppConstants.UI.Spacing.zero) {
      Picker("", selection: $selectedTab) {
        ForEach(TradeRequestTab.allCases) { tab in
          Text(tab.displayLabel).tag(tab)
        }
      }
      .pickerStyle(.segmented)
      .padding(.horizontal, AppConstants.UI.Padding.large)
      .padding(.top, AppConstants.UI.Padding.large)
      .onChange(of: selectedTab) { _, newTab in
        Self.logger.debug("Trade request tab changed to \(newTab.displayLabel)")
      }
      .onChange(of: currentUserId) { _, _ in
        cachedCurrentUser = nil
      }

      ScrollView {
        VStack(spacing: AppConstants.UI.Layout.Spacing.card) {
          if userTrades.isEmpty {
            emptyStateView
          } else {
            LazyVStack(spacing: AppConstants.UI.Layout.Spacing.card) {
              ForEach(userTrades) { trade in
                tradeCard(trade)
              }
            }
            .padding(.horizontal, AppConstants.UI.Padding.large)
          }
        }
        .padding(.vertical, AppConstants.UI.Padding.large)
      }
    }
    .alert(AppConstants.UI.Alerts.Titles.saveError, isPresented: $isShowingErrorAlert) {
      Button(AppConstants.UI.Alerts.Buttons.ok, role: AppConstants.UI.ButtonRole.cancel) {}
    } message: {
      Text(errorMessage)
    }
  }

  /*
   取引リクエストがない場合の空状態ビューを返します。
   */
  private var emptyStateView: some View {
    VStack(spacing: AppConstants.UI.Layout.Spacing.emptyState) {
      Image(systemName: AppConstants.UI.UIStrings.Content.envelopeFill)
        .font(AppConstants.UI.Typography.Font.emptyStateIcon)
        .foregroundStyle(.secondary)
      Text(AppConstants.UI.UIStrings.Profile.TradeRequests.empty)
        .font(AppConstants.UI.Typography.FontScale.sectionTitle)
      Text(AppConstants.UI.UIStrings.Profile.TradeRequests.emptyHint)
        .font(AppConstants.UI.Typography.Font.footnote)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity)
    .padding(.vertical, AppConstants.UI.Layout.Spacing.large)
  }

  /*
   取引リクエストカードを返します。
   */
  private func tradeCard(_ trade: Trade) -> some View {
    VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.section) {
      HStack {
        Text(trade.teaLeaf?.name ?? AppConstants.UI.UIStrings.Placeholders.unknown)
          .font(AppConstants.UI.Typography.FontScale.cardTitle)
        Spacer()
        Text(trade.status.rawValue)
          .font(AppConstants.UI.Typography.Font.caption.weight(AppConstants.UI.Typography.FontWeight.semibold))
          .foregroundStyle(statusColor(for: trade.status))
          .padding(.horizontal, AppConstants.UI.Padding.badgeHorizontal)
          .padding(.vertical, AppConstants.UI.Padding.badgeVertical)
          .background(statusColor(for: trade.status).opacity(AppConstants.UI.Opacity.badgeBackground))
          .clipShape(AppConstants.UI.ClipShape.capsule)
      }

      VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.medium) {
        detailRow(
          AppConstants.UI.UIStrings.Profile.TradeRequests.requester,
          value: trade.requester?.username ?? AppConstants.UI.UIStrings.Placeholders.unknown
        )
        detailRow(
          AppConstants.UI.UIStrings.Profile.TradeRequests.createdAt,
          value: AppConstants.DateFormatters.dateTimeFormatter.string(from: trade.createdAt)
        )
      }

      if selectedTab == .incoming && trade.status == .pending {
        HStack(spacing: AppConstants.UI.Layout.Spacing.chip) {
          Button(AppConstants.UI.UIStrings.Profile.TradeRequests.approve) {
            approveTrade(trade)
          }
          .buttonStyle(AppConstants.UI.ButtonStyle.borderedProminent)
          .tint(AppConstants.UI.BasicColor.green)

          Button(AppConstants.UI.UIStrings.Profile.TradeRequests.reject) {
            rejectTrade(trade)
          }
          .buttonStyle(AppConstants.UI.ButtonStyle.bordered)
          .tint(AppConstants.UI.BasicColor.red)
        }
      }
    }
    .padding(AppConstants.UI.Padding.cardHorizontal)
    .background(AppConstants.UI.BackgroundColor.cardWhite)
    .clipShape(AppConstants.UI.ClipShape.roundedRectangleCard)
    .shadow(color: AppConstants.UI.ShadowStyle.cardShadow, radius: AppConstants.UI.Shadow.cardRadius, x: 0, y: AppConstants.UI.Shadow.cardOffset)
  }

  /*
   タイトルと値の行を返します。
   */
  private func detailRow(_ title: String, value: String) -> some View {
    HStack {
      Text(title)
        .font(AppConstants.UI.Typography.Font.caption)
        .foregroundStyle(.secondary)
      Spacer()
      Text(value)
        .font(AppConstants.UI.Typography.Font.caption)
    }
  }

  /*
   ステータスに応じた色を返します。
   */
  private func statusColor(for status: TradeStatus) -> Color {
    switch status {
    case .pending:
      return AppConstants.UI.StatusColors.tradePending
    case .completed:
      return AppConstants.UI.StatusColors.tradeCompleted
    }
  }

  /*
   取引リクエストを承認します。
   */
  private func approveTrade(_ trade: Trade) {
    Self.logger.debug("Approving trade request for tea leaf: \(trade.teaLeaf?.name ?? "unknown")")
    trade.status = .completed
    trade.teaLeaf?.tradeStatus = .completed
    do {
      try modelContext.save()
      Self.logger.debug("Successfully approved trade request")
    } catch {
      Self.logger.error("Failed to approve trade request: \(error.localizedDescription)")
      errorMessage = AppConstants.UI.UIStrings.Profile.TradeRequests.Errors.approveFailed
      isShowingErrorAlert = true
    }
  }

  /*
   取引リクエストを拒否します。
   */
  private func rejectTrade(_ trade: Trade) {
    Self.logger.debug("Rejecting trade request for tea leaf: \(trade.teaLeaf?.name ?? "unknown")")
    modelContext.delete(trade)
    do {
      try modelContext.save()
      Self.logger.debug("Successfully rejected trade request")
    } catch {
      Self.logger.error("Failed to reject trade request: \(error.localizedDescription)")
      errorMessage = AppConstants.UI.UIStrings.Profile.TradeRequests.Errors.rejectFailed
      isShowingErrorAlert = true
    }
  }
}

#Preview {
  TradeRequestsView()
    .modelContainer(PreviewContainer.shared)
}
