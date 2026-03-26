import SwiftUI
import SwiftData

/*
 ユーザープロファイルを表示するビューです。
 */
struct ProfileView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var users: [User]
  @State private var isEditing = false
  @State private var editedUsername = ""
  @State private var editedLocation = ""
  @State private var isShowingSaveError = false
  @State private var saveErrorMessage = ""

  var body: some View {
    NavigationStack {
      if let user = users.first {
        VStack(alignment: .leading, spacing: 20) {
          Text("プロファイル")
            .font(.largeTitle)
            .fontWeight(.bold)

          VStack(alignment: .leading, spacing: 16) {
            if isEditing {
              VStack(alignment: .leading, spacing: 12) {
                TextField("ユーザー名", text: $editedUsername)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("場所", text: $editedLocation)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
              }
            } else {
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
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(isEditing ? "完了" : "編集") {
          if isEditing {
            saveProfileChanges()
          } else {
            startEditing()
          }
        }
      }
      if isEditing {
        ToolbarItem(placement: .topBarLeading) {
          Button("キャンセル", role: .cancel) {
            cancelEditing()
          }
        }
      }
    }
    .alert("保存に失敗しました", isPresented: $isShowingSaveError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(saveErrorMessage)
    }
  }

  /*
   編集モードを開始します。
   */
  private func startEditing() {
    if let user = users.first {
      editedUsername = user.username
      editedLocation = user.location
    }
    isEditing = true
  }

  /*
   編集をキャンセルして表示モードに戻します。
   */
  private func cancelEditing() {
    isEditing = false
  }

  /*
   プロファイルの変更を保存します。
   */
  private func saveProfileChanges() {
    guard let user = users.first else {
      saveErrorMessage = "ユーザーデータが見つかりません。"
      isShowingSaveError = true
      return
    }
    
    let trimmedUsername = editedUsername.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedLocation = editedLocation.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if trimmedUsername.isEmpty {
      saveErrorMessage = "ユーザー名は必須です。"
      isShowingSaveError = true
      return
    }
    
    if trimmedUsername.count < AppConstants.ValidationLimits.minUsernameLength {
      saveErrorMessage = "ユーザー名は\(AppConstants.ValidationLimits.minUsernameLength)文字以上で入力してください。"
      isShowingSaveError = true
      return
    }
    
    if trimmedUsername.count > AppConstants.ValidationLimits.maxUsernameLength {
      saveErrorMessage = "ユーザー名は\(AppConstants.ValidationLimits.maxUsernameLength)文字以下で入力してください。"
      isShowingSaveError = true
      return
    }
    
    if !trimmedLocation.isEmpty && trimmedLocation.count < AppConstants.ValidationLimits.minLocationLength {
      saveErrorMessage = "エリアは\(AppConstants.ValidationLimits.minLocationLength)文字以上で入力してください。"
      isShowingSaveError = true
      return
    }
    
    if !trimmedLocation.isEmpty && trimmedLocation.count > AppConstants.ValidationLimits.maxLocationLength {
      saveErrorMessage = "エリアは\(AppConstants.ValidationLimits.maxLocationLength)文字以下で入力してください。"
      isShowingSaveError = true
      return
    }
    
    user.username = trimmedUsername
    user.location = trimmedLocation.isEmpty ? "未設定" : trimmedLocation
    
    do {
      try modelContext.save()
      isEditing = false
    } catch {
      saveErrorMessage = "プロファイルの変更を保存できませんでした。時間をおいて再度お試しください。"
      isShowingSaveError = true
    }
  }
}

#Preview {
  ProfileView()
    .modelContainer(PreviewContainer.shared)
}
