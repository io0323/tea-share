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
  @State private var isPresentingAddTea = false

  private let columns = [
    GridItem(.flexible(), spacing: 12),
    GridItem(.flexible(), spacing: 12)
  ]

  /*
   表示条件に合う茶葉一覧を返します。
   */
  private var filteredTeaLeaves: [TeaLeaf] {
    let categoryFiltered = teaLeaves
      .filter { $0.tradeStatus == .available }
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

    return sortOption.sorted(textFiltered)
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
            categorySelector

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
   検索キーワード入力欄を返します。
   */
  private var searchField: some View {
    HStack(spacing: 8) {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(.secondary)
      TextField("茶葉名・ブランド・エリアで検索", text: $searchText)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(Color.white.opacity(0.9))
    .clipShape(RoundedRectangle(cornerRadius: 12))
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
