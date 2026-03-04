import SwiftUI
import SwiftData

/*
 茶葉カードから遷移する詳細画面です。
 */
struct TeaLeafDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Bindable var teaLeaf: TeaLeaf

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
        headerCard
        statusSection
        detailSection
      }
      .padding(16)
    }
    .navigationTitle("茶葉の詳細")
    .navigationBarTitleDisplayMode(.inline)
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
   残量や期限などの詳細情報を返します。
   */
  private var detailSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("詳細情報")
        .font(.headline)

      detailRow("残量", value: "\(teaLeaf.remainingGrams)g")
      detailRow("賞味期限", value: dateFormatter.string(from: teaLeaf.expiryDate))
      detailRow("出品者", value: teaLeaf.owner?.username ?? "未設定")
      detailRow("エリア", value: teaLeaf.owner?.location ?? "未設定")

      VStack(alignment: .leading, spacing: 6) {
        Text("説明")
          .font(.subheadline.weight(.semibold))
        Text(teaLeaf.description.isEmpty ? "説明は未入力です。" : teaLeaf.description)
          .font(.body)
          .foregroundStyle(.secondary)
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
}

#Preview {
  NavigationStack {
    TeaLeafDetailView(teaLeaf: PreviewContainer.sampleTeaLeaves[0])
  }
  .modelContainer(PreviewContainer.shared)
}
