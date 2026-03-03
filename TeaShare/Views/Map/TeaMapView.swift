import SwiftUI
import MapKit
import SwiftData

/*
 近隣の交換可能な茶葉を地図上に表示する画面です。
 */
struct TeaMapView: View {
  @Query(sort: \TeaLeaf.name) private var teaLeaves: [TeaLeaf]
  @State private var selectedTeaLeaf: TeaLeaf?
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
    teaLeaves.filter { $0.tradeStatus != .completed }
  }

  var body: some View {
    NavigationStack {
      Map(position: $cameraPosition) {
        ForEach(mapTeaLeaves) { teaLeaf in
          Annotation(teaLeaf.name, coordinate: teaLeaf.coordinate) {
            Button {
              selectedTeaLeaf = teaLeaf
            } label: {
              VStack(spacing: 4) {
                Image(systemName: "leaf.circle.fill")
                  .font(.system(size: 28))
                  .foregroundStyle(Color.green)
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
      .sheet(item: $selectedTeaLeaf) { teaLeaf in
        TeaMapDetailSheet(teaLeaf: teaLeaf)
          .presentationDetents([.fraction(0.35), .medium])
      }
    }
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
