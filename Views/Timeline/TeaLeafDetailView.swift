import SwiftUI
import SwiftData
import MapKit

/*
 茶葉カードから遷移する詳細画面です。
 */
struct TeaLeafDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Bindable var teaLeaf: TeaLeaf
  @State private var isEditingDetail = false
  @State private var editableRemainingGrams = 0
  @State private var editableExpiryDate = Date()
  @State private var editableDescription = ""
  @State private var isShowingSaveError = false

  private let descriptionLimit = 300

  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
  }()

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        if !teaLeaf.imagePath.isEmpty {
          imageSection
        }
        headerCard
        statusSection
        quickStatusSection
        tradeRequestSection
        detailSection
      }
      .padding(16)
    }
    .navigationTitle("茶葉の詳細")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(isEditingDetail ? "完了" : "編集") {
          if isEditingDetail {
            commitDetailEdits()
          } else {
            startEditingDetail()
          }
        }
      }
      if isEditingDetail {
        ToolbarItem(placement: .topBarLeading) {
          Button("キャンセル", role: .cancel) {
            cancelEditingDetail()
          }
        }
      }
    }
    .alert("保存に失敗しました", isPresented: $isShowingSaveError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("変更内容を保存できませんでした。時間をおいて再度お試しください。")
    }
    .onChange(of: editableDescription) { _, newValue in
      if newValue.count > descriptionLimit {
        editableDescription = String(newValue.prefix(descriptionLimit))
      }
    }
  }

  /*
   主要情報をまとめたヘッダーカードを返します。
   */
  private var headerCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(teaLeaf.name)
        .font(.title3.weight(.semibold))
      Text(teaLeaf.brand)
        .font(.subheadline)
        .foregroundStyle(.secondary)

      HStack(spacing: 8) {
        tagLabel(teaLeaf.category.rawValue, tint: .green)
        tagLabel(teaLeaf.tradeStatus.rawValue, tint: statusColor)
      }
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(0.92))
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
  }

  /*
   取引状態を変更するセクションを返します。
   */
  private var statusSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("取引ステータス")
        .font(.headline)

      Picker("取引ステータス", selection: $teaLeaf.tradeStatus) {
        ForEach(TradeStatus.allCases) { status in
          Text(status.rawValue).tag(status)
        }
      }
      .pickerStyle(.segmented)
      .onChange(of: teaLeaf.tradeStatus) { _, _ in
        saveContext()
      }
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(0.92))
    .clipShape(RoundedRectangle(cornerRadius: 14))
  }

  /*
   ワンタップで次ステータスへ進めるセクションを返します。
   */
  private var quickStatusSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("クイック操作")
        .font(.headline)

      Button {
        guard let nextStatus else { return }
        teaLeaf.tradeStatus = nextStatus
        saveContext()
      } label: {
        HStack {
          Image(systemName: "arrow.right.circle.fill")
          Text(quickActionTitle)
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .disabled(nextStatus == nil)
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(0.92))
    .clipShape(RoundedRectangle(cornerRadius: 14))
  }

  /*
   残量や期限などの詳細情報を返します。
   */
  private var detailSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("詳細情報")
          .font(.headline)
        Spacer()
        if isEditingDetail {
          Text("\(editableDescription.count)/\(descriptionLimit)")
            .font(.footnote)
            .foregroundStyle(
              editableDescription.count >= descriptionLimit
                ? .orange
                : .secondary
            )
        }
      }

      if isEditingDetail {
        Stepper(
          "残量: \(editableRemainingGrams)g",
          value: $editableRemainingGrams,
          in: 1...500,
          step: 5
        )
        DatePicker(
          "賞味期限",
          selection: $editableExpiryDate,
          displayedComponents: .date
        )
        TextField("説明", text: $editableDescription, axis: .vertical)
          .lineLimit(3...8)
      } else {
        detailRow("残量", value: "\(teaLeaf.remainingGrams)g")
        detailRow("賞味期限", value: dateFormatter.string(from: teaLeaf.expiryDate))
        detailRow("出品者", value: teaLeaf.owner?.username ?? "未設定")
        detailRow("エリア", value: teaLeaf.owner?.location ?? "未設定")
        detailRow("緯度", value: String(format: "%.5f", teaLeaf.latitude))
        detailRow("経度", value: String(format: "%.5f", teaLeaf.longitude))

        Button {
          openInMaps()
        } label: {
          HStack {
            Image(systemName: "map.fill")
            Text("マップで開く")
              .fontWeight(.semibold)
          }
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)

        VStack(alignment: .leading, spacing: 6) {
          Text("説明")
            .font(.subheadline.weight(.semibold))
          Text(teaLeaf.description.isEmpty ? "説明は未入力です。" : teaLeaf.description)
            .font(.body)
            .foregroundStyle(.secondary)
        }
      }
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(0.92))
    .clipShape(RoundedRectangle(cornerRadius: 14))
  }

  /*
   茶葉画像を表示するセクションを返します。
   */
  private var imageSection: some View {
    Group {
      if let uiImage = loadImage(from: teaLeaf.imagePath) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: 14))
          .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 3)
      } else {
        RoundedRectangle(cornerRadius: 14)
          .fill(Color.gray.opacity(0.2))
          .overlay {
            VStack(spacing: 8) {
              Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
              Text("画像を読み込めません")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
          .frame(height: 200)
      }
    }
  }

  /*
   取引リクエストセクションを返します。
   */
  private var tradeRequestSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("取引リクエスト")
        .font(.headline)

      if teaLeaf.tradeStatus == .available {
        Button {
          // TODO: 実際の取引リクエスト機能を実装
        } label: {
          HStack {
            Image(systemName: "envelope.fill")
            Text("取引を申し込む")
              .fontWeight(.semibold)
          }
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
      } else {
        HStack {
          Image(systemName: "info.circle.fill")
          Text(teaLeaf.tradeStatus == .pending ? "交渉中のため新規リクエストはできません" : "この取引は完了済みです")
            .font(.subheadline)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
      }
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(0.92))
    .clipShape(RoundedRectangle(cornerRadius: 14))
  }

  /*
   ステータスに応じた色を返します。
   */
  private var statusColor: Color {
    switch teaLeaf.tradeStatus {
    case .available:
      return .green
    case .pending:
      return .orange
    case .completed:
      return .gray
    }
  }

  /*
   現在のステータスから遷移可能な次ステータスを返します。
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
   クイック操作ボタンに表示する文言を返します。
   */
  private var quickActionTitle: String {
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
   タグ風ラベルを返します。
   */
  private func tagLabel(_ text: String, tint: Color) -> some View {
    Text(text)
      .font(.caption.weight(.semibold))
      .foregroundStyle(tint)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(tint.opacity(0.12))
      .clipShape(Capsule())
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

  /*
   タイトルと値の行を返します。
   */
  private func detailRow(_ title: String, value: String) -> some View {
    HStack {
      Text(title)
        .font(.subheadline.weight(.semibold))
      Spacer()
      Text(value)
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }

  /*
   コンテキスト保存を実行します。
   */
  private func saveContext() {
    do {
      try modelContext.save()
    } catch {
      /* 保存失敗時はUIを継続し、次回保存で再試行します。 */
    }
  }

  /*
   詳細情報の編集状態を開始します。
   */
  private func startEditingDetail() {
    editableRemainingGrams = teaLeaf.remainingGrams
    editableExpiryDate = teaLeaf.expiryDate
    editableDescription = teaLeaf.description
    isEditingDetail = true
  }

  /*
   詳細情報編集を破棄して表示モードへ戻します。
   */
  private func cancelEditingDetail() {
    isEditingDetail = false
  }

  /*
   編集内容をモデルへ反映して保存します。
   */
  private func commitDetailEdits() {
    teaLeaf.remainingGrams = editableRemainingGrams
    teaLeaf.expiryDate = editableExpiryDate
    teaLeaf.description = editableDescription
    do {
      try modelContext.save()
      isEditingDetail = false
    } catch {
      isShowingSaveError = true
    }
  }

  /*
   Apple Mapsで茶葉の位置情報を開きます。
   */
  private func openInMaps() {
    let coordinate = CLLocationCoordinate2D(
      latitude: teaLeaf.latitude,
      longitude: teaLeaf.longitude
    )
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = teaLeaf.name
    mapItem.openInMaps()
  }
}

#Preview {
  NavigationStack {
    TeaLeafDetailView(teaLeaf: PreviewContainer.sampleTeaLeaves[0])
  }
  .modelContainer(PreviewContainer.shared)
}
