import SwiftUI
import MapKit
import SwiftData

/*
 マップ表示用のステータスフィルタを管理する列挙型です。
 */
private enum TeaMapFilter: CaseIterable, Identifiable {
  case allActive
  case availableOnly
  case pendingOnly

  var id: String { String(describing: self) }

  /*
   フィルタチップに表示するラベルを返します。
   */
  var displayLabel: String {
    switch self {
    case .allActive:
      return AppConstants.UI.UIStrings.Map.Filters.allActive
    case .availableOnly:
      return AppConstants.UI.UIStrings.Map.Filters.availableOnly
    case .pendingOnly:
      return AppConstants.UI.UIStrings.Map.Filters.pendingOnly
    }
  }

  /*
   フィルタ条件に合うか判定します。
   */
  func matches(_ teaLeaf: TeaLeaf) -> Bool {
    switch self {
    case .allActive:
      return teaLeaf.tradeStatus != .completed
    case .availableOnly:
      return teaLeaf.tradeStatus == .available
    case .pendingOnly:
      return teaLeaf.tradeStatus == .pending
    }
  }
}

/*
 近隣の交換可能な茶葉を地図上に表示する画面です。
 */
struct TeaMapView: View {
  @Query(sort: \TeaLeaf.name) private var teaLeaves: [TeaLeaf]
  @State private var selectedTeaLeaf: TeaLeaf?
  @State private var selectedFilter: TeaMapFilter = .allActive
  @State private var selectedCategory: TeaCategory?
  @State private var cameraPosition: MapCameraPosition = .region(
    MKCoordinateRegion(
      center: CLLocationCoordinate2D(
        latitude: AppConstants.Location.defaultLatitude,
        longitude: AppConstants.Location.defaultLongitude
      ),
      span: MKCoordinateSpan(
        latitudeDelta: AppConstants.Map.defaultLatitudeDelta,
        longitudeDelta: AppConstants.Map.defaultLongitudeDelta
      )
    )
  )

  /*
   マップ上に表示する茶葉のみを返します。
   */
  private var mapTeaLeaves: [TeaLeaf] {
    teaLeaves
      .filter { selectedFilter.matches($0) }
      .filter { teaLeaf in
        guard let selectedCategory else { return true }
        return teaLeaf.category == selectedCategory
      }
  }

  var body: some View {
    NavigationStack {
      ZStack(alignment: .top) {
        Map(position: $cameraPosition) {
          ForEach(mapTeaLeaves) { teaLeaf in
            Annotation(teaLeaf.name, coordinate: teaLeaf.coordinate) {
              Button {
                selectedTeaLeaf = teaLeaf
              } label: {
                VStack(spacing: AppConstants.UI.Layout.Spacing.small) {
                  Image(systemName: AppConstants.UI.UIStrings.Content.leafCircleFill)
                    .font(.system(size: AppConstants.UI.FontSizes.mapMarkerIcon))
                    .foregroundStyle(markerColor(for: teaLeaf.tradeStatus))
                  Text(teaLeaf.category.rawValue)
                    .font(AppConstants.UI.Typography.Font.caption2)
                    .padding(.horizontal, AppConstants.UI.Padding.buttonHorizontal)
                    .padding(.vertical, AppConstants.UI.Padding.buttonVertical)
                    .background(AppConstants.UI.BackgroundColor.whiteHigh)
                    .clipShape(AppConstants.UI.ClipShape.capsule)
                }
              }
              .buttonStyle(AppConstants.UI.ButtonStyle.plain)
            }
          }
        }
        .navigationTitle(AppConstants.UI.Navigation.Titles.map)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              focusOnDefaultRegion()
            } label: {
              Image(systemName: AppConstants.UI.UIStrings.Content.location)
            }
            .accessibilityLabel(AppConstants.UI.UIStrings.Actions.focusOnDefaultArea)
          }
        }
        .sheet(item: $selectedTeaLeaf) { teaLeaf in
          TeaMapDetailSheet(teaLeaf: teaLeaf)
            .presentationDetents([.fraction(AppConstants.UI.Sheets.Detents.mapDetailFraction), AppConstants.UI.Sheets.Detents.mapDetailMedium])
        }

        VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.section) {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppConstants.UI.Layout.Spacing.chip) {
              ForEach(TeaMapFilter.allCases) { filter in
                filterChip(filter)
              }
            }
          }

          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppConstants.UI.Layout.Spacing.chip) {
              categoryChip(
                title: AppConstants.UI.UIStrings.Labels.allCategories,
                category: nil
              )
              ForEach(TeaCategory.allCases) { category in
                categoryChip(title: category.rawValue, category: category)
              }
            }
          }

          Button {
            resetFilters()
          } label: {
            HStack(spacing: AppConstants.UI.Layout.Spacing.chip) {
              Image(
                systemName: AppConstants.UI.UIStrings.Content.arrowCounterclockwise
              )
              Text(AppConstants.UI.UIStrings.Labels.clearFilter)
            }
            .font(AppConstants.UI.Typography.Font.caption.weight(AppConstants.UI.Typography.FontWeight.semibold))
            .padding(.horizontal, AppConstants.UI.Padding.buttonHorizontal)
            .padding(.vertical, AppConstants.UI.Padding.buttonVertical)
            .padding(.vertical, AppConstants.UI.Padding.filterButtonVertical)
            .background(Color.white.opacity(AppConstants.UI.Opacity.whiteHigh))
            .clipShape(AppConstants.UI.ClipShape.capsule)
          }
          .buttonStyle(AppConstants.UI.ButtonStyle.plain)

          Text(AppConstants.UI.UIStrings.Labels.displayCount.replacingOccurrences(of: "{count}", with: "\(mapTeaLeaves.count)"))
            .font(AppConstants.UI.Typography.Font.footnote.weight(AppConstants.UI.Typography.FontWeight.medium))
            .padding(.horizontal, AppConstants.UI.Padding.chipHorizontal)
            .padding(.vertical, AppConstants.UI.Padding.chipVertical)
            .background(Color.white.opacity(AppConstants.UI.Opacity.whiteHigh))
            .clipShape(AppConstants.UI.ClipShape.capsule)
        }
        .padding(.horizontal, AppConstants.UI.Padding.default)
        .padding(.top, AppConstants.UI.Padding.top)
      }
    }
  }

  /*
   ステータス色を返します。
   */
  private func markerColor(for status: TradeStatus) -> Color {
    switch status {
    case .available:
      return .green
    case .pending:
      return .orange
    case .completed:
      return .gray
    }
  }

  /*
   フィルタ選択チップを返します。
   */
  private func filterChip(_ filter: TeaMapFilter) -> some View {
    Button {
      selectedFilter = filter
    } label: {
      Text(filter.displayLabel)
        .font(AppConstants.UI.Typography.Font.caption.weight(AppConstants.UI.Typography.FontWeight.semibold))
        .foregroundStyle(
          selectedFilter == filter ? Color.white : Color.green.opacity(AppConstants.UI.Opacity.filterUnselected)
        )
        .padding(.horizontal, AppConstants.UI.Padding.chipHorizontal)
        .padding(.vertical, AppConstants.UI.Padding.filterButtonVertical)
        .background(
          selectedFilter == filter
            ? Color.green.opacity(AppConstants.UI.Opacity.filterSelected)
            : Color.white.opacity(AppConstants.UI.Opacity.filterUnselected)
        )
        .clipShape(AppConstants.UI.ClipShape.capsule)
    }
    .buttonStyle(AppConstants.UI.ButtonStyle.plain)
  }

  /*
   カテゴリ選択チップを返します。
   */
  private func categoryChip(
    title: String,
    category: TeaCategory?
  ) -> some View {
    let isSelected = selectedCategory == category
    return Button {
      selectedCategory = category
    } label: {
      Text(title)
        .font(AppConstants.UI.Typography.Font.caption.weight(AppConstants.UI.Typography.FontWeight.semibold))
        .foregroundStyle(
          isSelected ? Color.white : Color.blue.opacity(AppConstants.UI.Opacity.filterUnselected)
        )
        .padding(.horizontal, AppConstants.UI.Padding.chipHorizontal)
        .padding(.vertical, AppConstants.UI.Padding.filterButtonVertical)
        .background(
          isSelected
            ? Color.blue.opacity(AppConstants.UI.Opacity.categorySelected)
            : Color.white.opacity(AppConstants.UI.Opacity.filterUnselected)
        )
        .clipShape(AppConstants.UI.ClipShape.capsule)
    }
    .buttonStyle(AppConstants.UI.ButtonStyle.plain)
  }

  /*
   ステータスとカテゴリの絞り込みを初期化します。
   */
  private func resetFilters() {
    selectedFilter = .allActive
    selectedCategory = nil
  }

  /*
   地図表示を既定の中心エリアに戻します。
   */
  private func focusOnDefaultRegion() {
    let region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(
        latitude: AppConstants.Location.defaultLatitude,
        longitude: AppConstants.Location.defaultLongitude
      ),
      span: MKCoordinateSpan(
        latitudeDelta: AppConstants.Map.defaultLatitudeDelta,
        longitudeDelta: AppConstants.Map.defaultLongitudeDelta
      )
    )
    cameraPosition = .region(region)
  }
}

/*
 マップピン選択時のハーフモーダル詳細です。
 */
private struct TeaMapDetailSheet: View {
  @Environment(\.modelContext) private var modelContext
  @Bindable var teaLeaf: TeaLeaf
  @State private var isShowingSaveError = AppConstants.Defaults.UI.isShowingSaveError
  @State private var saveErrorMessage = AppConstants.Defaults.State.saveErrorMessage

  var body: some View {
    VStack(alignment: .leading, spacing: AppConstants.UI.Spacing.default) {
      Capsule()
        .fill(AppConstants.UI.FillColor.secondary)
        .frame(height: AppConstants.UI.Frame.errorImageHeight)
        .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity, alignment: AppConstants.UI.FrameAlignment.center)
        .padding(.top, AppConstants.UI.Padding.default)

      Text(teaLeaf.name)
        .font(AppConstants.UI.Typography.Font.title3.weight(AppConstants.UI.Typography.FontWeight.semibold))

      Text(AppConstants.UI.UIStrings.Labels.seller.replacingOccurrences(of: "{username}", with: teaLeaf.owner?.username ?? AppConstants.UI.UIStrings.Placeholders.unknown))
        .font(AppConstants.UI.Typography.Font.body)
      Text(AppConstants.UI.UIStrings.Labels.area.replacingOccurrences(of: "{location}", with: teaLeaf.owner?.location ?? AppConstants.UI.UIStrings.Placeholders.notSet))
        .font(AppConstants.UI.Typography.Font.body)
      Text(AppConstants.UI.UIStrings.Labels.remaining.replacingOccurrences(of: "{grams}", with: "\(teaLeaf.remainingGrams)"))
        .font(AppConstants.UI.Typography.Font.body)
      Text(AppConstants.UI.UIStrings.Labels.status.replacingOccurrences(of: "{status}", with: teaLeaf.tradeStatus.rawValue))
        .font(AppConstants.UI.Typography.Font.body)
        .foregroundStyle(.secondary)

      VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.vStack) {
        Text(AppConstants.UI.UIStrings.Labels.updateTradeStatus)
          .font(AppConstants.UI.Typography.FontScale.sectionSubtitle)
        Picker(
          AppConstants.UI.UIStrings.Labels.tradeStatus,
          selection: $teaLeaf.tradeStatus
        ) {
          ForEach(TradeStatus.allCases) { status in
            Text(status.rawValue).tag(status)
          }
        }
        .pickerStyle(.segmented)
        .onChange(of: teaLeaf.tradeStatus) { _, _ in
          saveStatusChange()
        }
      }

      Button {
        moveToNextStatus()
      } label: {
        HStack {
          Image(systemName: AppConstants.UI.UIStrings.Content.arrowRightCircleFill)
          Text(nextActionTitle)
            .fontWeight(AppConstants.UI.Typography.FontWeight.semibold)
        }
        .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity)
      }
      .buttonStyle(AppConstants.UI.ButtonStyle.borderedProminent)
      .disabled(nextStatus == nil)

      Spacer()
    }
    .padding(.horizontal, AppConstants.UI.Padding.huge)
    .padding(.bottom, AppConstants.UI.Padding.bottom)
    .alert(AppConstants.UI.Alerts.Titles.saveError, isPresented: $isShowingSaveError) {
      Button(AppConstants.UI.Alerts.Buttons.ok, role: .cancel) {}
    } message: {
      Text(saveErrorMessage)
    }
  }

  /*
   現在ステータスから次に進めるステータスを返します。
   */
  private var nextStatus: TradeStatus? {
    switch teaLeaf.tradeStatus {
    case .available:
      return .pending
    case .pending:
      return .completed
    case .completed:
      return nil
    }
  }

  /*
   クイック更新ボタンの表示文言を返します。
   */
  private var nextActionTitle: String {
    switch teaLeaf.tradeStatus {
    case .available:
      return AppConstants.UI.UIStrings.Detail.QuickActions.moveToPending
    case .pending:
      return AppConstants.UI.UIStrings.Detail.QuickActions.moveToCompleted
    case .completed:
      return AppConstants.UI.UIStrings.Detail.QuickActions.alreadyCompleted
    }
  }

  /*
   次ステータスへ進めて保存を行います。
   */
  private func moveToNextStatus() {
    guard let nextStatus else { return }
    teaLeaf.tradeStatus = nextStatus
    saveStatusChange()
  }

  /*
   ステータス変更を永続化します。
   */
  private func saveStatusChange() {
    do {
      try modelContext.save()
    } catch {
      saveErrorMessage =
        AppConstants.UI.UIStrings.Detail.SaveErrors.statusUpdateFailed
      isShowingSaveError = true
    }
  }
}

#Preview {
  TeaMapView()
    .modelContainer(PreviewContainer.shared)
}
