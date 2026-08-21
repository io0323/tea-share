import SwiftUI
import SwiftData

/*
 ユーザーが出品した茶葉の一覧を表示するビューです。
 */
struct MyListingsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var teaLeaves: [TeaLeaf]
  @AppStorage(AppConstants.Storage.currentUserIdKey)
  private var currentUserId = ""

  /*
   現在ユーザーが出品した茶葉のみを返します。
   */
  private var myListings: [TeaLeaf] {
    guard let currentUser = CurrentUserManager.fetchCurrentUser(
      modelContext: modelContext,
      storedUserId: currentUserId
    ) else {
      return []
    }
    return teaLeaves.filter { $0.owner?.id == currentUser.id }
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

/*
 茶葉情報をカードで表示する子ビューです。
 */
private struct TeaLeafCardView: View {
  let tea: TeaLeaf

  var body: some View {
    VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.vStack) {
      // 画像表示エリア
      if !tea.imagePath.isEmpty,
         let uiImage = TeaImageStorage.loadImage(from: tea.imagePath) {
        Image(uiImage: uiImage)
          .resizable()
          .aspectRatio(
            contentMode: AppConstants.UI.ImageScaling.scaledToFill
          )
          .frame(height: AppConstants.UI.Frame.cardHeight)
          .clipShape(AppConstants.UI.ClipShape.roundedRectangleLarge)
      } else {
        RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.large)
          .fill(AppConstants.UI.FillColor.green)
          .overlay {
            Image(systemName: AppConstants.UI.UIStrings.Content.leafFill)
              .font(.system(size: AppConstants.UI.FontSizes.cardIcon))
              .foregroundStyle(Color.green.opacity(AppConstants.UI.Colors.greenForegroundOpacity))
          }
          .frame(height: AppConstants.UI.Frame.cardHeight)
          .clipShape(AppConstants.UI.ClipShape.roundedRectangleSheet)
      }

      Text(tea.name)
        .font(AppConstants.UI.Typography.FontScale.cardTitle)
        .lineLimit(2)

      HStack(spacing: AppConstants.UI.Layout.Spacing.hStack) {
        Text(tea.category.rawValue)
          .font(AppConstants.UI.Typography.FontScale.cardSubtitle)
          .padding(.horizontal, AppConstants.UI.Padding.badgeHorizontal)
          .padding(.vertical, AppConstants.UI.Padding.badgeVertical)
          .background(Color.green.opacity(AppConstants.UI.Colors.greenBadgeOpacity))
          .clipShape(AppConstants.UI.ClipShape.capsule)
        statusBadge
      }

      expiryBadge

      VStack(alignment: .leading, spacing: 2) {
        Text(
          StringFormatter.format(AppConstants.UI.UIStrings.Labels.remaining, key: "grams", value: tea.remainingGrams)
        )
          .font(AppConstants.UI.Typography.Font.caption)
        Text(
          StringFormatter.format(
            AppConstants.UI.UIStrings.Labels.area,
            key: "location",
            value: tea.owner?.location ?? AppConstants.UI.UIStrings.Placeholders.notSet
          )
        )
          .font(AppConstants.UI.Typography.Font.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding(AppConstants.UI.Padding.cardHorizontal)
    .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity, alignment: AppConstants.UI.FrameAlignment.leading)
    .background(AppConstants.UI.BackgroundColor.cardWhite)
    .clipShape(AppConstants.UI.ClipShape.roundedRectangleCard)
    .shadow(color: AppConstants.UI.ShadowStyle.cardShadow, radius: AppConstants.UI.Shadow.cardRadius, x: 0, y: AppConstants.UI.Shadow.cardOffset)
  }

  /*
   期限情報のバッジ表示を返します。
   */
  private var expiryBadge: some View {
    HStack(spacing: AppConstants.UI.Layout.Spacing.medium) {
      Image(systemName: expiryIcon)
      Text(expiryText)
    }
    .font(AppConstants.UI.Typography.Font.caption2.weight(AppConstants.UI.Typography.FontWeight.semibold))
    .foregroundStyle(expiryColor)
    .padding(.horizontal, AppConstants.UI.Padding.badgeHorizontal)
    .padding(.vertical, AppConstants.UI.Padding.badgeVertical)
    .background(expiryColor.opacity(AppConstants.UI.Opacity.badgeBackground))
    .clipShape(AppConstants.UI.ClipShape.capsule)
  }

  /*
   期限状態に応じたラベル文言を返します。
   */
  private var expiryText: String {
    switch tea.expiryStatus {
    case .expired:
      return AppConstants.UI.UIStrings.Timeline.Expiry.expired
    case .expiringSoon:
      return StringFormatter.format(
        AppConstants.UI.UIStrings.Timeline.Expiry.daysRemaining,
        key: "days",
        value: tea.daysUntilExpiry
      )
    case .fresh:
      return AppConstants.UI.UIStrings.Timeline.Expiry.fresh
    }
  }

  /*
   期限状態に応じた色を返します。
   */
  private var expiryColor: Color {
    switch tea.expiryStatus {
    case .expired:
      return .red
    case .expiringSoon:
      return .orange
    case .fresh:
      return .green
    }
  }

  /*
   期限状態に応じたアイコンを返します。
   */
  private var expiryIcon: String {
    switch tea.expiryStatus {
    case .expired:
      return AppConstants.UI.UIStrings.Content.exclamationmarkTriangleFill
    case .expiringSoon:
      return AppConstants.UI.UIStrings.Content.clockFill
    case .fresh:
      return AppConstants.UI.UIStrings.Content.checkmarkSealFill
    }
  }

  /*
   取引状態のバッジ表示を返します。
   */
  private var statusBadge: some View {
    Text(tea.tradeStatus.rawValue)
      .font(AppConstants.UI.Typography.Font.caption2.weight(AppConstants.UI.Typography.FontWeight.semibold))
      .foregroundStyle(statusColor)
      .padding(.horizontal, AppConstants.UI.Padding.badgeHorizontal)
      .padding(.vertical, AppConstants.UI.Padding.badgeVertical)
      .background(statusColor.opacity(AppConstants.UI.Opacity.badgeBackground))
      .clipShape(AppConstants.UI.ClipShape.capsule)
  }

  /*
   取引状態に応じた色を返します。
   */
  private var statusColor: Color {
    switch tea.tradeStatus {
    case .available:
      return .green
    case .pending:
      return .orange
    case .completed:
      return .gray
    }
  }
}

#Preview {
  MyListingsView()
    .modelContainer(PreviewContainer.shared)
}
