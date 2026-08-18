import SwiftUI
import SwiftData

/*
 募集中の茶葉を一覧表示するメインタイムラインです。
 */
struct TeaTimelineView: View {
  @Query(sort: \TeaLeaf.expiryDate) private var teaLeaves: [TeaLeaf]
  @State private var selectedCategory: TeaCategory?
  @State private var searchText = AppConstants.Defaults.State.searchText
  @State private var sortOption: TeaTimelineSortOption = AppConstants.Defaults.Selection.sortOption
  @State private var statusScope: TeaTimelineStatusScope = AppConstants.Defaults.Selection.statusScope
  @State private var showExpiringOnly = AppConstants.Defaults.UI.showExpiringOnly
  @State private var isPresentingAddTea = AppConstants.Defaults.UI.isPresentingAddTea

  private let columns = [
    GridItem(.flexible(), spacing: AppConstants.UI.Layout.Spacing.grid),
    GridItem(.flexible(), spacing: AppConstants.UI.Layout.Spacing.grid)
  ]

  /*
   表示条件に合う茶葉一覧を返します。
   */
  private var filteredTeaLeaves: [TeaLeaf] {
    let categoryFiltered = scopedTeaLeaves
      .filter { tea in
        guard let selectedCategory else { return true }
        return tea.category == selectedCategory
      }

    let textFiltered = categoryFiltered.filter { tea in
      let keyword = searchText
        .trimmingCharacters(in: .whitespacesAndNewlines)
      guard !keyword.isEmpty else { return true }
      return tea.name.localizedCaseInsensitiveContains(keyword)
        || tea.brand.localizedCaseInsensitiveContains(keyword)
        || (tea.owner?.location ?? "").localizedCaseInsensitiveContains(keyword)
    }

    let expiryFiltered = textFiltered.filter { tea in
      guard showExpiringOnly else { return true }
      return tea.expiryStatus != .fresh
    }

    return sortOption.sorted(expiryFiltered)
  }

  /*
   ステータス表示範囲適用後の件数を返します。
   */
  private var scopedTeaLeaves: [TeaLeaf] {
    teaLeaves.filter { statusScope.matches($0.tradeStatus) }
  }

  /*
   絞り込み適用後の件数を返します。
   */
  private var filteredCount: Int {
    filteredTeaLeaves.count
  }

  /*
   現在有効なフィルタ条件ラベルを返します。
   */
  private var activeFilterLabels: [String] {
    var labels: [String] = []
    let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    if !keyword.isEmpty {
      labels.append(
        AppConstants.UI.UIStrings.Timeline.FilterLabels.search
          .replacingOccurrences(of: "{keyword}", with: keyword)
      )
    }
    if let selectedCategory {
      labels.append(
        AppConstants.UI.UIStrings.Timeline.FilterLabels.category
          .replacingOccurrences(of: "{category}", with: selectedCategory.rawValue)
      )
    }
    if statusScope != .active {
      labels.append(
        AppConstants.UI.UIStrings.Timeline.FilterLabels.scope
          .replacingOccurrences(of: "{scope}", with: statusScope.displayLabel)
      )
    }
    if showExpiringOnly {
      labels.append(
        AppConstants.UI.UIStrings.Timeline.FilterLabels.expiringOnly
      )
    }
    if sortOption != .expirySoon {
      labels.append(
        AppConstants.UI.UIStrings.Timeline.FilterLabels.sort
          .replacingOccurrences(of: "{sort}", with: sortOption.displayLabel)
      )
    }
    return labels
  }

  /*
   フィルタ条件が一つでも有効か判定します。
   */
  private var hasActiveFilters: Bool {
    !activeFilterLabels.isEmpty
  }

  /*
   期限切れまたは期限間近の件数を返します。
   */
  private var expiringCount: Int {
    scopedTeaLeaves
      .filter { $0.expiryStatus != .fresh }
      .count
  }

  /*
   取引ステータス別の件数を返します。
   */
  private var tradeStatusCounts: [TradeStatus: Int] {
    let grouped = Dictionary(grouping: teaLeaves, by: \.tradeStatus)
    return [
      .available: grouped[.available]?.count ?? 0,
      .pending: grouped[.pending]?.count ?? 0,
      .completed: grouped[.completed]?.count ?? 0
    ]
  }

  var body: some View {
    NavigationStack {
      ZStack(alignment: .bottomTrailing) {
        LinearGradient(
          colors: [
            Color(red: 0.86, green: 0.94, blue: 0.86),
            Color(red: 0.95, green: 0.91, blue: 0.84)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .opacity(AppConstants.UI.Opacity.backgroundGradient)

        ScrollView {
          VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.card) {
            searchField
            sortSelector
            statusScopeSelector
            expiryToggle
            categorySelector
            activeFilterSummary
            timelineSummary
            tradeStatusSummaryCards

            if filteredTeaLeaves.isEmpty {
              emptyStateView
            } else {
              LazyVGrid(columns: columns, spacing: AppConstants.UI.Layout.Spacing.grid) {
                ForEach(filteredTeaLeaves) { tea in
                  NavigationLink {
                    TeaLeafDetailView(teaLeaf: tea)
                  } label: {
                    TeaLeafCardView(tea: tea)
                  }
                  .buttonStyle(AppConstants.UI.ButtonStyle.plain)
                }
              }
              .padding(.horizontal, AppConstants.UI.Padding.large)
              .padding(.vertical, AppConstants.UI.Padding.large)
            }
          }
          .padding(.horizontal, AppConstants.UI.Padding.large)
          .padding(.vertical, AppConstants.UI.Padding.large)
        }

        Button(action: { isPresentingAddTea = true }) {
          HStack(spacing: AppConstants.UI.Layout.Spacing.tag) {
            Image(systemName: AppConstants.UI.UIStrings.Content.plusIcon)
            Text(AppConstants.UI.UIStrings.Content.plus)
          }
          .font(AppConstants.UI.Typography.FontScale.buttonTitle)
          .foregroundStyle(AppConstants.UI.BasicColor.white)
          .padding(.horizontal, AppConstants.UI.Padding.default)
          .padding(.vertical, AppConstants.UI.Padding.large)
          .background(Color.green.opacity(AppConstants.UI.Opacity.greenButton))
          .clipShape(AppConstants.UI.ClipShape.capsule)
          .shadow(color: AppConstants.UI.ShadowStyle.shadow, radius: AppConstants.UI.Shadow.largeRadius, x: 0, y: AppConstants.UI.Shadow.buttonOffset)
        }
          .padding(AppConstants.UI.Padding.huge)
      }
      .navigationTitle(AppConstants.UI.Navigation.Titles.main)
      .sheet(isPresented: $isPresentingAddTea) {
        AddTeaView()
      }
    }
  }

  /*
   検索キーワード入力欄を返します。
   */
  private var searchField: some View {
    HStack(spacing: AppConstants.UI.Layout.Spacing.hStack) {
      Image(systemName: AppConstants.UI.UIStrings.Content.magnifyingglass)
        .foregroundStyle(.secondary)
      TextField(
        AppConstants.UI.UIStrings.Timeline.Search.placeholder,
        text: $searchText
      )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
      if !searchText.isEmpty {
        Button {
          searchText = ""
        } label: {
          Image(systemName: AppConstants.UI.UIStrings.Content.xmarkCircleFill)
            .foregroundStyle(.secondary)
        }
      }
    }
    .padding(.horizontal, AppConstants.UI.Padding.cardHorizontal)
    .padding(.vertical, AppConstants.UI.Padding.cardVertical)
    .background(AppConstants.UI.BackgroundColor.whiteHigh)
    .clipShape(AppConstants.UI.ClipShape.roundedRectangleLarge)
  }

  /*
   並び替えを切り替えるセレクターを返します。
   */
  private var sortSelector: some View {
    Picker(AppConstants.UI.UIStrings.Labels.sortBy, selection: $sortOption) {
      ForEach(TeaTimelineSortOption.allCases) { option in
        Text(option.displayLabel).tag(option)
      }
    }
    .pickerStyle(.segmented)
  }

  /*
   募集状態の表示範囲を切り替えるセレクターを返します。
   */
  private var statusScopeSelector: some View {
    Picker(AppConstants.UI.UIStrings.Labels.displayScope, selection: $statusScope) {
      ForEach(TeaTimelineStatusScope.allCases) { scope in
        Text(scope.displayLabel).tag(scope)
      }
    }
    .pickerStyle(.segmented)
  }

  /*
   期限切れ・期限間近の絞り込みトグルを返します。
   */
  private var expiryToggle: some View {
    Toggle(isOn: $showExpiringOnly) {
      Text(AppConstants.UI.UIStrings.Labels.expiringOnly)
        .font(AppConstants.UI.Typography.FontScale.sectionSubtitle)
    }
    .toggleStyle(.switch)
  }

  /*
   横スクロール可能なカテゴリ選択UIを返します。
   */
  private var categorySelector: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: AppConstants.UI.Layout.Spacing.hStack) {
        CategoryChip(
          title: AppConstants.UI.UIStrings.Labels.allCategories,
          isSelected: selectedCategory == nil
        ) {
          selectedCategory = nil
        }

        ForEach(TeaCategory.allCases) { category in
          CategoryChip(
            title: category.rawValue,
            isSelected: selectedCategory == category
          ) {
            selectedCategory = category
          }
        }
      }
      .padding(.vertical, AppConstants.UI.Padding.verticalSmall)
    }
  }

  /*
   一覧の集計情報を返します。
   */
  private var timelineSummary: some View {
    HStack {
      Text(AppConstants.UI.UIStrings.Labels.targetCount.replacingOccurrences(of: "{count}", with: "\(scopedTeaLeaves.count)"))
      Spacer()
      Text(AppConstants.UI.UIStrings.Labels.resultCount.replacingOccurrences(of: "{count}", with: "\(filteredCount)"))
      Spacer()
      Text(AppConstants.UI.UIStrings.Labels.expiringCount.replacingOccurrences(of: "{count}", with: "\(expiringCount)"))
    }
    .font(AppConstants.UI.Typography.FontScale.chipTitle)
    .foregroundStyle(.secondary)
  }

  /*
   取引ステータス別サマリーカード群を返します。
   */
  private var tradeStatusSummaryCards: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: AppConstants.UI.Layout.Spacing.section) {
        statusSummaryCard(
          title: TradeStatus.available.rawValue,
          count: tradeStatusCounts[.available] ?? 0,
          icon: AppConstants.UI.UIStrings.Content.leafFill,
          tint: .green
        )
        statusSummaryCard(
          title: TradeStatus.pending.rawValue,
          count: tradeStatusCounts[.pending] ?? 0,
          icon: AppConstants.UI.UIStrings.Content.bubbleLeftAndBubbleRightFill,
          tint: .orange
        )
        statusSummaryCard(
          title: TradeStatus.completed.rawValue,
          count: tradeStatusCounts[.completed] ?? 0,
          icon: AppConstants.UI.UIStrings.Content.checkmarkSealFill,
          tint: .gray
        )
      }
      .padding(.vertical, AppConstants.UI.Padding.verticalSmall)
    }
  }

  /*
   ステータス件数表示カードを返します。
   */
  private func statusSummaryCard(
    title: String,
    count: Int,
    icon: String,
    tint: Color
  ) -> some View {
    HStack(spacing: AppConstants.UI.Layout.Spacing.hStack) {
      Image(systemName: icon)
        .foregroundStyle(tint)
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(AppConstants.UI.Typography.Font.caption)
          .foregroundStyle(.secondary)
        Text(
          AppConstants.UI.UIStrings.Labels.countSuffix
            .replacingOccurrences(of: "{count}", with: "\(count)")
        )
          .font(AppConstants.UI.Typography.FontScale.sectionTitle)
      }
    }
    .padding(.horizontal, AppConstants.UI.Padding.medium)
    .padding(.vertical, AppConstants.UI.Padding.extraLarge)
    .background(AppConstants.UI.BackgroundColor.whiteHigh)
    .clipShape(AppConstants.UI.ClipShape.roundedRectangleSheet)
  }

  /*
   結果が0件のときの空状態ビューを返します。
   */
  private var emptyStateView: some View {
    VStack(spacing: AppConstants.UI.Layout.Spacing.emptyState) {
      Image(systemName: AppConstants.UI.UIStrings.Content.tray)
        .font(.system(size: AppConstants.UI.FontSizes.emptyStateIcon))
        .foregroundStyle(.secondary)
      Text(AppConstants.UI.UIStrings.Labels.noMatchingTea)
        .font(AppConstants.UI.Typography.FontScale.sectionTitle)
      Text(AppConstants.UI.UIStrings.Labels.changeSearchConditions)
        .font(AppConstants.UI.Typography.Font.footnote)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity)
    .padding(.vertical, AppConstants.UI.Layout.Spacing.large)
    .background(AppConstants.UI.BackgroundColor.cardBackground)
    .clipShape(AppConstants.UI.ClipShape.roundedRectangleExtraLarge)
  }

  /*
   アクティブなフィルタ状態と解除操作を返します。
   */
  private var activeFilterSummary: some View {
    VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.medium) {
      if hasActiveFilters {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: AppConstants.UI.Layout.Spacing.tag) {
            ForEach(activeFilterLabels, id: \.self) { label in
              Text(label)
                .font(AppConstants.UI.Typography.Font.caption.weight(AppConstants.UI.Typography.FontWeight.semibold))
                .padding(.horizontal, AppConstants.UI.Padding.filterHorizontal)
                .padding(.vertical, AppConstants.UI.Padding.filterVertical)
                .background(AppConstants.UI.BackgroundColor.whiteHigh)
                .clipShape(AppConstants.UI.ClipShape.capsule)
            }
          }
        }

        Button(AppConstants.UI.UIStrings.Labels.clearAllConditions) {
          resetAllFilters()
        }
        .font(AppConstants.UI.Typography.FontScale.chipTitle)
      } else {
        Text(AppConstants.UI.UIStrings.Labels.noFilterConditions)
          .font(AppConstants.UI.Typography.Font.footnote)
          .foregroundStyle(.secondary)
      }
    }
  }

  /*
   フィルタ条件を初期状態へ戻します。
   */
  private func resetAllFilters() {
    selectedCategory = nil
    searchText = ""
    sortOption = .expirySoon
    statusScope = .active
    showExpiringOnly = false
  }
}

/*
 タイムラインの並び順を管理する列挙型です。
 */
private enum TeaTimelineSortOption: CaseIterable, Identifiable {
  case expirySoon
  case remainingHigh
  case name

  var id: String { String(describing: self) }

  /*
   並び替えラベルを返します。
   */
  var displayLabel: String {
    switch self {
    case .expirySoon:
      return AppConstants.UI.UIStrings.Timeline.Sort.expirySoon
    case .remainingHigh:
      return AppConstants.UI.UIStrings.Timeline.Sort.remainingHigh
    case .name:
      return AppConstants.UI.UIStrings.Timeline.Sort.name
    }
  }

  /*
   選択された並び順で配列をソートします。
   */
  func sorted(_ teaLeaves: [TeaLeaf]) -> [TeaLeaf] {
    switch self {
    case .expirySoon:
      return teaLeaves.sorted { $0.expiryDate < $1.expiryDate }
    case .remainingHigh:
      return teaLeaves.sorted { $0.remainingGrams > $1.remainingGrams }
    case .name:
      return teaLeaves.sorted {
        $0.name.localizedCompare($1.name) == .orderedAscending
      }
    }
  }
}

/*
 タイムラインで表示する取引状態の範囲を管理する列挙型です。
 */
private enum TeaTimelineStatusScope: CaseIterable, Identifiable {
  case active
  case availableOnly

  var id: String { String(describing: self) }

  /*
   表示範囲ラベルを返します。
   */
  var displayLabel: String {
    switch self {
    case .active:
      return AppConstants.UI.UIStrings.Timeline.StatusScope.active
    case .availableOnly:
      return AppConstants.UI.UIStrings.Timeline.StatusScope.availableOnly
    }
  }

  /*
   ステータスが表示対象か判定します。
   */
  func matches(_ status: TradeStatus) -> Bool {
    switch self {
    case .active:
      return status == .available || status == .pending
    case .availableOnly:
      return status == .available
    }
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
          AppConstants.UI.UIStrings.Labels.remaining
            .replacingOccurrences(of: "{grams}", with: "\(tea.remainingGrams)")
        )
          .font(AppConstants.UI.Typography.Font.caption)
        Text(
          AppConstants.UI.UIStrings.Labels.area
            .replacingOccurrences(
              of: "{location}",
              with: tea.owner?.location
                ?? AppConstants.UI.UIStrings.Placeholders.notSet
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
      return AppConstants.UI.UIStrings.Timeline.Expiry.daysRemaining
        .replacingOccurrences(of: "{days}", with: "\(tea.daysUntilExpiry)")
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

/*
 カテゴリを切り替えるチップUIです。
 */
private struct CategoryChip: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(AppConstants.UI.Typography.Font.subheadline.weight(AppConstants.UI.Typography.FontWeight.medium))
        .foregroundStyle(isSelected ? .white : Color.green.opacity(AppConstants.UI.Colors.greenTextOpacity))
        .padding(.horizontal, AppConstants.UI.Padding.buttonHorizontal)
        .padding(.vertical, AppConstants.UI.Padding.buttonVertical)
        .background(
          isSelected
            ? Color.green.opacity(AppConstants.UI.Colors.greenSelectedOpacity)
            : Color.white.opacity(AppConstants.UI.Opacity.chipBackground)
        )
        .clipShape(AppConstants.UI.ClipShape.capsule)
    }
  }
}

#Preview {
  TeaTimelineView()
    .modelContainer(PreviewContainer.shared)
}
