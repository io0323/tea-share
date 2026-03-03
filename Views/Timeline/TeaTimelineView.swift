import SwiftUI
import SwiftData

/*
 募集中の茶葉を一覧表示するメインタイムラインです。
 */
struct TeaTimelineView: View {
  @Query(sort: \TeaLeaf.expiryDate) private var teaLeaves: [TeaLeaf]
  @State private var selectedCategory: TeaCategory?
  @State private var isPresentingAddTea = false

  private let columns = [
    GridItem(.flexible(), spacing: 12),
    GridItem(.flexible(), spacing: 12)
  ]

  /*
   表示条件に合う茶葉一覧を返します。
   */
  private var filteredTeaLeaves: [TeaLeaf] {
    teaLeaves
      .filter { $0.tradeStatus == .available }
      .filter { tea in
        guard let selectedCategory else { return true }
        return tea.category == selectedCategory
      }
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
            categorySelector

            LazyVGrid(columns: columns, spacing: 12) {
              ForEach(filteredTeaLeaves) { tea in
                TeaLeafCardView(tea: tea)
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
          .font(.headline)
          .foregroundStyle(.white)
          .padding(.horizontal, 16)
          .padding(.vertical, 14)
          .background(Color.green.opacity(0.85))
          .clipShape(Capsule())
          .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 3)
        }
        .padding(20)
      }
      .navigationTitle("TeaShare")
      .sheet(isPresented: $isPresentingAddTea) {
        AddTeaView()
      }
    }
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
}

/*
 茶葉情報をカードで表示する子ビューです。
 */
private struct TeaLeafCardView: View {
  let tea: TeaLeaf

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.green.opacity(0.10))
        .overlay {
          Image(systemName: "leaf.fill")
            .font(.system(size: 26))
            .foregroundStyle(Color.green.opacity(0.65))
        }
        .frame(height: 86)

      Text(tea.name)
        .font(.headline)
        .lineLimit(2)

      Text(tea.category.rawValue)
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.green.opacity(0.12))
        .clipShape(Capsule())

      VStack(alignment: .leading, spacing: 2) {
        Text("残量: \(tea.remainingGrams)g")
          .font(.caption)
        Text("エリア: \(tea.owner?.location ?? "未設定")")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(0.92))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: .black.opacity(0.07), radius: 7, x: 0, y: 2)
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
        .foregroundStyle(isSelected ? .white : Color.green.opacity(0.9))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
          isSelected
            ? Color.green.opacity(0.80)
            : Color.white.opacity(0.85)
        )
        .clipShape(Capsule())
    }
  }
}

#Preview {
  TeaTimelineView()
    .modelContainer(PreviewContainer.shared)
}
