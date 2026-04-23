import SwiftUI
import MapKit
import SwiftData

/*
 マップ表示用のステータスフィルタを管理する列挙型です。
 */
private enum TeaMapFilter: String, CaseIterable, Identifiable {
  case allActive = "募集中+交渉中"
  case availableOnly = "募集中のみ"
  case pendingOnly = "交渉中のみ"

  var id: String { rawValue }

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
                  Image(systemName: "leaf.circle.fill")
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
              categoryChip(title: "すべて", category: nil)
              ForEach(TeaCategory.allCases) { category in
                categoryChip(title: category.rawValue, category: category)
              }
            }
          }

          Button {
            resetFilters()
          } label: {
            HStack(spacing: AppConstants.UI.Layout.Spacing.chip) {
              Image(systemName: "arrow.counterclockwise")
              Text(AppConstants.UI.UIStrings.Labels.clearFilter)
            }
            .font(.caption.weight(.semibold))
            .padding(.horizontal, AppConstants.UI.Padding.buttonHorizontal)
            .padding(.vertical, AppConstants.UI.Padding.buttonVertical)
            .padding(.vertical, 7)
            .background(Color.white.opacity(AppConstants.UI.Opacity.whiteHigh))
            .clipShape(AppConstants.UI.ClipShape.capsule)
          }
          .buttonStyle(AppConstants.UI.ButtonStyle.plain)

          Text(AppConstants.UI.UIStrings.Labels.displayCount.replacingOccurrences(of: "{count}", with: "\(mapTeaLeaves.count)"))
            .font(.footnote.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(AppConstants.UI.Opacity.whiteHigh))
            .clipShape(AppConstants.UI.ClipShape.capsule)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
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
      Text(filter.rawValue)
        .font(.caption.weight(.semibold))
        .foregroundStyle(
          selectedFilter == filter ? Color.white : Color.green.opacity(AppConstants.UI.Opacity.filterUnselected)
        )
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
          selectedFilter == filter
            ? Color.green.opacity(AppConstants.UI.Opacity.filterSelected)
            : Color.white.opacity(AppConstants.UI.Opacity.filterUnselected)
        )
        .clipShape(AppConstants.UI.ClipShape.capsule)
    }
    .buttonStyle(.plain)
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
        .font(.caption.weight(.semibold))
        .foregroundStyle(
          isSelected ? Color.white : Color.blue.opacity(AppConstants.UI.Opacity.filterUnselected)
        )
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
          isSelected
            ? Color.blue.opacity(AppConstants.UI.Opacity.categorySelected)
            : Color.white.opacity(AppConstants.UI.Opacity.filterUnselected)
        )
        .clipShape(AppConstants.UI.ClipShape.capsule)
    }
    .buttonStyle(.plain)
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
  @State private var isShowingSaveError = AppConstants.AppConstants.Defaults.UI.isShowingSaveError
  @State private var saveErrorMessage = AppConstants.AppConstants.Defaults.State.saveErrorMessage

  var body: some View {
    VStack(alignment: .leading, spacing: AppConstants.UI.Spacing.default) {
      Capsule()
        .fill(AppConstants.UI.FillColor.secondary)
        .frame(height: AppConstants.UI.Frame.errorImageHeight)
        .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity, alignment: AppConstants.UI.FrameAlignment.center)
        .padding(.top, AppConstants.UI.Padding.default)

      Text(teaLeaf.name)
        .font(.title3.weight(.semibold))

      Text(AppConstants.UI.UIStrings.Labels.seller.replacingOccurrences(of: "{username}", with: teaLeaf.owner?.username ?? AppConstants.UI.UIStrings.Placeholders.unknown))
        .font(AppConstants.UI.Typography.Font.body)
      Text(AppConstants.UI.UIStrings.Labels.area.replacingOccurrences(of: "{location}", with: teaLeaf.owner?.location ?? AppConstants.UI.UIStrings.Placeholders.notSet))
        .font(AppConstants.UI.Typography.Font.body)
      Text(AppConstants.UI.UIStrings.Labels.remaining.replacingOccurrences(of: "{grams}", with: "\(teaLeaf.remainingGrams)"))
        .font(AppConstants.UI.Typography.Font.body)
      Text(AppConstants.UI.UIStrings.Labels.status.replacingOccurrences(of: "{status}", with: teaLeaf.tradeStatus.rawValue))
        .font(AppConstants.UI.Typography.Font.body)
        .foregroundStyle(.secondary)

      VStack(alignment: .leading, spacing: 8) {
        Text(AppConstants.UI.UIStrings.Labels.updateTradeStatus)
          .font(AppConstants.UI.Typography.FontScale.sectionSubtitle)
        Picker("取引ステータス", selection: $teaLeaf.tradeStatus) {
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
          Image(systemName: "arrow.right.circle.fill")
          Text(nextActionTitle)
            .fontWeight(AppConstants.UI.Typography.FontWeight.semibold)
        }
        .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity)
      }
      .buttonStyle(AppConstants.UI.ButtonStyle.borderedProminent)
      .disabled(nextStatus == nil)

      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 20)
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
      return "交渉中へ進める"
    case .pending:
      return "交換完了へ進める"
    case .completed:
      return "この取引は完了済みです"
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
      saveErrorMessage = "ステータス更新を保存できませんでした。時間をおいて再度お試しください。"
      isShowingSaveError = true
    }
  }
}

#Preview {
  TeaMapView()
    .modelContainer(PreviewContainer.shared)
}
