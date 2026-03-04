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
  @State private var cameraPosition: MapCameraPosition = .region(
    MKCoordinateRegion(
      center: CLLocationCoordinate2D(
        latitude: 35.681236,
        longitude: 139.767125
      ),
      span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )
  )

  /*
   マップ上に表示する茶葉のみを返します。
   */
  private var mapTeaLeaves: [TeaLeaf] {
    teaLeaves.filter { selectedFilter.matches($0) }
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
                VStack(spacing: 4) {
                  Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(markerColor(for: teaLeaf.tradeStatus))
                  Text(teaLeaf.category.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())
                }
              }
              .buttonStyle(.plain)
            }
          }
        }
        .navigationTitle("交換スポット")
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              focusOnDefaultRegion()
            } label: {
              Image(systemName: "location")
            }
            .accessibilityLabel("中心エリアへ戻る")
          }
        }
        .sheet(item: $selectedTeaLeaf) { teaLeaf in
          TeaMapDetailSheet(teaLeaf: teaLeaf)
            .presentationDetents([.fraction(0.35), .medium])
        }

        VStack(alignment: .leading, spacing: 10) {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              ForEach(TeaMapFilter.allCases) { filter in
                filterChip(filter)
              }
            }
          }

          Text("表示中: \(mapTeaLeaves.count)件")
            .font(.footnote.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.9))
            .clipShape(Capsule())
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
          selectedFilter == filter ? Color.white : Color.green.opacity(0.9)
        )
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
          selectedFilter == filter
            ? Color.green.opacity(0.9)
            : Color.white.opacity(0.9)
        )
        .clipShape(Capsule())
    }
    .buttonStyle(.plain)
  }

  /*
   地図表示を既定の中心エリアに戻します。
   */
  private func focusOnDefaultRegion() {
    let region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(
        latitude: 35.681236,
        longitude: 139.767125
      ),
      span: MKCoordinateSpan(
        latitudeDelta: 0.15,
        longitudeDelta: 0.15
      )
    )
    cameraPosition = .region(region)
  }
}

/*
 マップピン選択時のハーフモーダル詳細です。
 */
private struct TeaMapDetailSheet: View {
  let teaLeaf: TeaLeaf

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Capsule()
        .fill(Color.secondary.opacity(0.3))
        .frame(width: 44, height: 5)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 6)

      Text(teaLeaf.name)
        .font(.title3.weight(.semibold))

      Text("出品者: \(teaLeaf.owner?.username ?? "不明")")
        .font(.body)
      Text("エリア: \(teaLeaf.owner?.location ?? "未設定")")
        .font(.body)
      Text("残量: \(teaLeaf.remainingGrams)g")
        .font(.body)
      Text("ステータス: \(teaLeaf.tradeStatus.rawValue)")
        .font(.body)
        .foregroundStyle(.secondary)

      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 20)
  }
}

#Preview {
  TeaMapView()
    .modelContainer(PreviewContainer.shared)
}
