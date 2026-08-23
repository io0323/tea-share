import SwiftUI
import SwiftData

/*
 取引リクエストの一覧を表示するビューです。
 */
struct TradeRequestsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var trades: [Trade]
  @AppStorage(AppConstants.Storage.currentUserIdKey)
  private var currentUserId = ""
  @State private var selectedTab: TradeRequestTab = .incoming

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
    guard let currentUser = CurrentUserManager.fetchCurrentUser(
      modelContext: modelContext,
      storedUserId: currentUserId
    ) else {
      return []
    }

    switch selectedTab {
    case .incoming:
      return trades.filter { $0.owner?.id == currentUser.id }
    case .outgoing:
      return trades.filter { $0.requester?.id == currentUser.id }
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      Picker("", selection: $selectedTab) {
        ForEach(TradeRequestTab.allCases) { tab in
          Text(tab.displayLabel).tag(tab)
        }
      }
      .pickerStyle(.segmented)
      .padding(.horizontal, AppConstants.UI.Padding.large)
      .padding(.top, AppConstants.UI.Padding.large)

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
  }

  /*
   取引リクエストがない場合の空状態ビューを返します。
   */
  private var emptyStateView: some View {
    VStack(spacing: AppConstants.UI.Layout.Spacing.emptyState) {
      Image(systemName: AppConstants.UI.UIStrings.Content.envelopeFill)
        .font(.system(size: AppConstants.UI.FontSizes.emptyStateIcon))
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
          value: DateFormatterHelper.formatDateTime(trade.createdAt)
        )
      }

      if selectedTab == .incoming && trade.status == .pending {
        HStack(spacing: AppConstants.UI.Layout.Spacing.chip) {
          Button(AppConstants.UI.UIStrings.Profile.TradeRequests.approve) {
            approveTrade(trade)
          }
          .buttonStyle(AppConstants.UI.ButtonStyle.borderedProminent)
          .tint(.green)

          Button(AppConstants.UI.UIStrings.Profile.TradeRequests.reject) {
            rejectTrade(trade)
          }
          .buttonStyle(AppConstants.UI.ButtonStyle.bordered)
          .tint(.red)
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
      return .orange
    case .completed:
      return .green
    }
  }

  /*
   取引リクエストを承認します。
   */
  private func approveTrade(_ trade: Trade) {
    trade.status = .completed
    trade.teaLeaf?.tradeStatus = .completed
    do {
      try modelContext.save()
    } catch {
      // エラーハンドリングが必要なら追加
    }
  }

  /*
   取引リクエストを拒否します。
   */
  private func rejectTrade(_ trade: Trade) {
    modelContext.delete(trade)
    do {
      try modelContext.save()
    } catch {
      // エラーハンドリングが必要なら追加
    }
  }
}

#Preview {
  TradeRequestsView()
    .modelContainer(PreviewContainer.shared)
}
