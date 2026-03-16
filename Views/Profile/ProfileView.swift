import SwiftUI
import SwiftData

/*
 ユーザープロファイルを表示するビューです。
 */
struct ProfileView: View {
  @Query private var users: [User]
  @State private var isEditing = false
  @State private var editedUsername = ""
  @State private var editedLocation = ""

  var body: some View {
    NavigationStack {
      if let user = users.first {
        VStack(alignment: .leading, spacing: 20) {
          Text("プロファイル")
            .font(.largeTitle)
            .fontWeight(.bold)

          VStack(alignment: .leading, spacing: 16) {
            HStack {
              Text("ユーザー名:")
                .font(.headline)
              Text(user.username)
                .font(.body)
            }

            HStack {
              Text("ID:")
                .font(.headline)
              Text(user.id.uuidString)
                .font(.body)
                .foregroundColor(.secondary)
            }

            HStack {
              Text("場所:")
                .font(.headline)
              Text(user.location)
                .font(.body)
            }
          }
          .padding()
          .background(Color.gray.opacity(0.1))
          .cornerRadius(10)

          Spacer()
        }
        .padding()
      } else {
        Text("ユーザーデータが見つかりません")
          .font(.title)
          .foregroundColor(.gray)
      }
    }
    .navigationTitle("プロファイル")
  }
}

#Preview {
  ProfileView()
    .modelContainer(PreviewContainer.shared)
}
