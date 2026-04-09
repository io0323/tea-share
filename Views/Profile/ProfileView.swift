import SwiftUI
import SwiftData

/*
 ユーザープロファイルを表示するビューです。
 */
struct ProfileView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var users: [User]
  @State private var isEditing = AppConstants.AppConstants.Defaults.UI.isEditing
  @State private var editedUsername = AppConstants.AppConstants.Defaults.State.editedUsername
  @State private var editedLocation = AppConstants.AppConstants.Defaults.State.editedLocation
  @State private var isShowingSaveError = AppConstants.AppConstants.Defaults.UI.isShowingSaveError
  @State private var saveErrorMessage = AppConstants.AppConstants.Defaults.State.saveErrorMessage

  var body: some View {
    NavigationStack {
      if let user = users.first {
        VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.card) {
          Text("プロファイル")
            .font(AppConstants.UI.Typography.Font.largeTitle)
            .fontWeight(.bold)

          VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.card) {
            if isEditing {
              VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.form) {
                TextField("ユーザー名", text: $editedUsername)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("場所", text: $editedLocation)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
              }
            } else {
              HStack {
                Text(AppConstants.UI.UIStrings.Labels.username)
                  .font(AppConstants.UI.Typography.FontScale.sectionTitle)
                Text(user.username)
                  .font(AppConstants.UI.Typography.Font.body)
              }

              HStack {
                Text(AppConstants.UI.UIStrings.Labels.id)
                  .font(AppConstants.UI.Typography.FontScale.sectionTitle)
                Text(user.id.uuidString)
                  .font(AppConstants.UI.Typography.Font.body)
                  .foregroundColor(.secondary)
              }

              HStack {
                Text(AppConstants.UI.UIStrings.Labels.location)
                  .font(AppConstants.UI.Typography.FontScale.sectionTitle)
                Text(user.location)
                  .font(AppConstants.UI.Typography.Font.body)
              }
            }
          }
          .padding()
          .background(Color.gray.opacity(AppConstants.UI.Opacity.grayLight))
          .cornerRadius(AppConstants.UI.CornerRadius.card)

          Spacer()
        }
        .padding()
      } else {
        Text(AppConstants.UI.UIStrings.Labels.userDataNotFound)
          .font(AppConstants.UI.Typography.Font.title)
          .foregroundColor(.gray)
      }
    }
    .navigationTitle(AppConstants.UI.Navigation.Titles.profile)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(isEditing ? AppConstants.UI.Navigation.Toolbar.Buttons.done : AppConstants.UI.Navigation.Toolbar.Buttons.edit) {
          if isEditing {
            saveProfileChanges()
          } else {
            startEditing()
          }
        }
      }
      if isEditing {
        ToolbarItem(placement: .topBarLeading) {
          Button(AppConstants.UI.Navigation.Toolbar.Buttons.cancel, role: .cancel) {
            cancelEditing()
          }
        }
      }
    }
    .alert(AppConstants.UI.Alerts.Titles.saveError, isPresented: $isShowingSaveError) {
      Button(AppConstants.UI.Alerts.Buttons.ok, role: .cancel) {}
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
