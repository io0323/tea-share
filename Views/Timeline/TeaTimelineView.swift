import SwiftUI
import SwiftData

/*
 募集中の茶葉を一覧表示するメインタイムラインです。
 */
struct TeaTimelineView: View {
  @Query(sort: \TeaLeaf.expiryDate) private var teaLeaves: [TeaLeaf]
  @State private var selectedCategory: TeaCategory?
  @State private var searchText = ""
  @State private var sortOption: TeaTimelineSortOption = .expirySoon
  @State private var statusScope: TeaTimelineStatusScope = .active
  @State private var showExpiringOnly = false
  @State private var isPresentingAddTea = false

  private let columns = [
    GridItem(.flexible(), spacing: 12),
    GridItem(.flexible(), spacing: 12)
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
      labels.append("検索: \(keyword)")
    }
    if let selectedCategory {
      labels.append("カテゴリ: \(selectedCategory.rawValue)")
    }
    if statusScope != .active {
      labels.append("範囲: \(statusScope.rawValue)")
    }
    if showExpiringOnly {
      labels.append("期限注意のみ")
    }
    if sortOption != .expirySoon {
      labels.append("並び: \(sortOption.rawValue)")
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
        .opacity(0.25)

        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
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
              LazyVGrid(columns: columns, spacing: 12) {
                ForEach(filteredTeaLeaves) { tea in
                  NavigationLink {
                    TeaLeafDetailView(teaLeaf: tea)
                  } label: {
                    TeaLeafCardView(tea: tea)
                  }
                  .buttonStyle(.plain)
                }
              }
            }
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
        }

        Button(action: { isPresentingAddTea = true }) {
          HStack(spacing: 8) {
            Image(systemName: "plus")
            Text("出品する")
          }
          .font(AppConstants.UI.Typography.FontScale.buttonTitle)
          .foregroundStyle(.white)
          .padding(.horizontal, 16)
          .padding(.vertical, 14)
          .background(Color.green.opacity(AppConstants.UI.Opacity.greenButton))
          .clipShape(Capsule())
          .shadow(color: .black.opacity(AppConstants.UI.Opacity.shadow), radius: AppConstants.UI.Shadow.largeRadius, x: 0, y: AppConstants.UI.Shadow.buttonOffset)
        }
          .padding(AppConstants.UI.Padding.huge)
      }
      .navigationTitle("TeaShare")
      .sheet(isPresented: $isPresentingAddTea) {
        AddTeaView()
      }
    }
  }

  /*
   検索キーワード入力欄を返します。
   */
  private var searchField: some View {
    HStack(spacing: 8) {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(.secondary)
      TextField("茶葉名・ブランド・エリアで検索", text: $searchText)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
      if !searchText.isEmpty {
        Button {
          searchText = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.secondary)
        }
      }
    }
    .padding(.horizontal, AppConstants.UI.Padding.cardHorizontal)
    .padding(.vertical, AppConstants.UI.Padding.cardVertical)
    .background(Color.white.opacity(AppConstants.UI.Opacity.backgroundWhite))
    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.large))
  }

  /*
   並び替えを切り替えるセレクターを返します。
   */
  private var sortSelector: some View {
    Picker("並び替え", selection: $sortOption) {
      ForEach(TeaTimelineSortOption.allCases) { option in
        Text(option.rawValue).tag(option)
      }
    }
    .pickerStyle(.segmented)
  }

  /*
   募集状態の表示範囲を切り替えるセレクターを返します。
   */
  private var statusScopeSelector: some View {
    Picker("表示範囲", selection: $statusScope) {
      ForEach(TeaTimelineStatusScope.allCases) { scope in
        Text(scope.rawValue).tag(scope)
      }
    }
    .pickerStyle(.segmented)
  }

  /*
   期限切れ・期限間近の絞り込みトグルを返します。
   */
  private var expiryToggle: some View {
    Toggle(isOn: $showExpiringOnly) {
      Text("期限切れ/期限間近のみ")
        .font(AppConstants.UI.Typography.FontScale.sectionSubtitle)
    }
    .toggleStyle(.switch)
  }

  /*
   横スクロール可能なカテゴリ選択UIを返します。
   */
  private var categorySelector: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        CategoryChip(
          title: "すべて",
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
      .padding(.vertical, 2)
    }
  }

  /*
   一覧の集計情報を返します。
   */
  private var timelineSummary: some View {
    HStack {
      Text("対象: \(scopedTeaLeaves.count)件")
      Spacer()
      Text("結果: \(filteredCount)件")
      Spacer()
      Text("期限注意: \(expiringCount)件")
    }
    .font(.footnote.weight(.medium))
    .foregroundStyle(.secondary)
  }

  /*
   取引ステータス別サマリーカード群を返します。
   */
  private var tradeStatusSummaryCards: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 10) {
        statusSummaryCard(
          title: TradeStatus.available.rawValue,
          count: tradeStatusCounts[.available] ?? 0,
          icon: "leaf.fill",
          tint: .green
        )
        statusSummaryCard(
          title: TradeStatus.pending.rawValue,
          count: tradeStatusCounts[.pending] ?? 0,
          icon: "bubble.left.and.bubble.right.fill",
          tint: .orange
        )
        statusSummaryCard(
          title: TradeStatus.completed.rawValue,
          count: tradeStatusCounts[.completed] ?? 0,
          icon: "checkmark.seal.fill",
          tint: .gray
        )
      }
      .padding(.vertical, 2)
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
    HStack(spacing: 8) {
      Image(systemName: icon)
        .foregroundStyle(tint)
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.caption)
          .foregroundStyle(.secondary)
        Text("\(count)件")
          .font(AppConstants.UI.Typography.FontScale.sectionTitle)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(Color.white.opacity(0.9))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  /*
   結果が0件のときの空状態ビューを返します。
   */
  private var emptyStateView: some View {
    VStack(spacing: 10) {
      Image(systemName: "tray")
        .font(.system(size: AppConstants.UI.FontSizes.emptyStateIcon))
        .foregroundStyle(.secondary)
      Text("条件に一致する茶葉がありません")
        .font(AppConstants.UI.Typography.FontScale.sectionTitle)
      Text("検索条件やカテゴリを変更してください")
        .font(AppConstants.UI.Typography.Font.footnote)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, AppConstants.UI.Layout.Spacing.large)
    .background(Color.white.opacity(AppConstants.UI.Opacity.cardBackground))
    .clipShape(RoundedRectangle(cornerRadius: 14))
  }

  /*
   アクティブなフィルタ状態と解除操作を返します。
   */
  private var activeFilterSummary: some View {
    VStack(alignment: .leading, spacing: 8) {
      if hasActiveFilters {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(activeFilterLabels, id: \.self) { label in
              Text(label)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, AppConstants.UI.Padding.filterHorizontal)
                .padding(.vertical, AppConstants.UI.Padding.filterVertical)
                .background(Color.white.opacity(AppConstants.UI.Opacity.backgroundWhite))
                .clipShape(Capsule())
            }
          }
        }

        Button("条件をすべて解除") {
          resetAllFilters()
        }
        .font(.footnote.weight(.semibold))
      } else {
        Text("フィルタ条件は未設定です")
          .font(.footnote)
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
private enum TeaTimelineSortOption: String, CaseIterable, Identifiable {
  case expirySoon = "期限順"
  case remainingHigh = "残量順"
  case name = "名前順"

  var id: String { rawValue }

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
private enum TeaTimelineStatusScope: String, CaseIterable, Identifiable {
  case active = "募集中+交渉中"
  case availableOnly = "募集中のみ"

  var id: String { rawValue }

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
    VStack(alignment: .leading, spacing: 8) {
      // 画像表示エリア
      if !tea.imagePath.isEmpty, let uiImage = loadImage(from: tea.imagePath) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
          .frame(height: AppConstants.UI.Frame.cardHeight)
          .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.large))
      } else {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.green.opacity(AppConstants.UI.Colors.greenOpacity))
          .overlay {
            Image(systemName: "leaf.fill")
              .font(.system(size: AppConstants.UI.FontSizes.cardIcon))
              .foregroundStyle(Color.green.opacity(AppConstants.UI.Colors.greenForegroundOpacity))
          }
          .frame(height: AppConstants.UI.Frame.cardHeight)
      }

      Text(tea.name)
        .font(AppConstants.UI.Typography.FontScale.cardTitle)
        .lineLimit(2)

      HStack(spacing: 6) {
        Text(tea.category.rawValue)
          .font(AppConstants.UI.Typography.FontScale.cardSubtitle)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color.green.opacity(AppConstants.UI.Colors.greenBadgeOpacity))
          .clipShape(Capsule())
        statusBadge
      }

      expiryBadge

      VStack(alignment: .leading, spacing: 2) {
        Text("残量: \(tea.remainingGrams)g")
          .font(.caption)
        Text("エリア: \(tea.owner?.location ?? "未設定")")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding(AppConstants.UI.Padding.cardHorizontal)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(AppConstants.UI.Opacity.cardWhite))
    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.card))
    .shadow(color: .black.opacity(AppConstants.UI.Opacity.cardShadow), radius: AppConstants.UI.Shadow.cardRadius, x: 0, y: AppConstants.UI.Shadow.cardOffset)
  }

  /*
   期限情報のバッジ表示を返します。
   */
  private var expiryBadge: some View {
    HStack(spacing: 6) {
      Image(systemName: expiryIcon)
      Text(expiryText)
    }
    .font(.caption2.weight(.semibold))
    .foregroundStyle(expiryColor)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(expiryColor.opacity(0.12))
    .clipShape(Capsule())
  }

  /*
   期限状態に応じたラベル文言を返します。
   */
  private var expiryText: String {
    switch tea.expiryStatus {
    case .expired:
      return "期限切れ"
    case .expiringSoon:
      return "残り\(tea.daysUntilExpiry)日"
    case .fresh:
      return "余裕あり"
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
      return "exclamationmark.triangle.fill"
    case .expiringSoon:
      return "clock.fill"
    case .fresh:
      return "checkmark.seal.fill"
    }
  }

  /*
   取引状態のバッジ表示を返します。
   */
  private var statusBadge: some View {
    Text(tea.tradeStatus.rawValue)
      .font(.caption2.weight(.semibold))
      .foregroundStyle(statusColor)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(statusColor.opacity(0.12))
      .clipShape(Capsule())
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

  /*
   ファイルパスから画像を読み込みます。
   */
  private func loadImage(from path: String) -> UIImage? {
    guard !path.isEmpty else { return nil }
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: path) else { return nil }
    return UIImage(contentsOfFile: path)
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
        .font(.subheadline.weight(.medium))
        .foregroundStyle(isSelected ? .white : Color.green.opacity(AppConstants.UI.Colors.greenTextOpacity))
        .padding(.horizontal, AppConstants.UI.Padding.buttonHorizontal)
        .padding(.vertical, AppConstants.UI.Padding.buttonVertical)
        .background(
          isSelected
            ? Color.green.opacity(AppConstants.UI.Colors.greenSelectedOpacity)
            : Color.white.opacity(AppConstants.UI.Opacity.chipBackground)
        )
        .clipShape(Capsule())
    }
  }
}

#Preview {
  TeaTimelineView()
    .modelContainer(PreviewContainer.shared)
}
