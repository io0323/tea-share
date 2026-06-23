import SwiftUI
import SwiftData

/*
 ユーザープロファイルを表示するビューです。
 */
struct ProfileView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var users: [User]
  @State private var isEditing = AppConstants.Defaults.UI.isEditing
  @State private var editedUsername = AppConstants.Defaults.State.editedUsername
  @State private var editedLocation = AppConstants.Defaults.State.editedLocation
  @State private var isShowingSaveError = AppConstants.Defaults.UI.isShowingSaveError
  @State private var saveErrorMessage = AppConstants.Defaults.State.saveErrorMessage

  var body: some View {
    NavigationStack {
      if let user = users.first {
        VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.card) {
          Text(AppConstants.UI.UIStrings.Labels.profile)
            .font(AppConstants.UI.Typography.Font.largeTitle)
            .fontWeight(AppConstants.UI.Typography.FontWeight.bold)

          VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.card) {
            if isEditing {
              VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.form) {
                TextField(
                  AppConstants.UI.UIStrings.Labels.username,
                  text: $editedUsername
                )
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField(
                  AppConstants.UI.UIStrings.Labels.location,
                  text: $editedLocation
                )
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
          .padding(AppConstants.UI.Padding.default)
          .background(Color.gray.opacity(AppConstants.UI.Opacity.grayLight))
          .cornerRadius(AppConstants.UI.CornerRadius.card)

          Spacer()
        }
        .padding(AppConstants.UI.Padding.default)
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
      saveErrorMessage =
        AppConstants.UI.UIStrings.Profile.SaveErrors.userNotFound
      isShowingSaveError = true
      return
    }
    
    let trimmedUsername = editedUsername.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedLocation = editedLocation.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if trimmedUsername.isEmpty {
      saveErrorMessage =
        AppConstants.UI.UIStrings.AddTea.Validation.usernameRequired
      isShowingSaveError = true
      return
    }
    
    if trimmedUsername.count < AppConstants.ValidationLimits.minUsernameLength {
      saveErrorMessage =
        AppConstants.UI.UIStrings.AddTea.Validation.usernameMinLength
          .replacingOccurrences(
            of: "{min}",
            with: "\(AppConstants.ValidationLimits.minUsernameLength)"
          )
      isShowingSaveError = true
      return
    }
    
    if trimmedUsername.count > AppConstants.ValidationLimits.maxUsernameLength {
      saveErrorMessage =
        AppConstants.UI.UIStrings.AddTea.Validation.usernameMaxLength
          .replacingOccurrences(
            of: "{max}",
            with: "\(AppConstants.ValidationLimits.maxUsernameLength)"
          )
      isShowingSaveError = true
      return
    }
    
    if !trimmedLocation.isEmpty
      && trimmedLocation.count < AppConstants.ValidationLimits.minLocationLength {
      saveErrorMessage =
        AppConstants.UI.UIStrings.AddTea.Validation.areaMinLength
          .replacingOccurrences(
            of: "{min}",
            with: "\(AppConstants.ValidationLimits.minLocationLength)"
          )
      isShowingSaveError = true
      return
    }
    
    if !trimmedLocation.isEmpty
      && trimmedLocation.count > AppConstants.ValidationLimits.maxLocationLength {
      saveErrorMessage =
        AppConstants.UI.UIStrings.AddTea.Validation.areaMaxLength
          .replacingOccurrences(
            of: "{max}",
            with: "\(AppConstants.ValidationLimits.maxLocationLength)"
          )
      isShowingSaveError = true
      return
    }
    
    user.username = trimmedUsername
    user.location = trimmedLocation.isEmpty
      ? AppConstants.UI.UIStrings.Placeholders.notSet
      : trimmedLocation
    
    do {
      try modelContext.save()
      isEditing = false
    } catch {
      saveErrorMessage =
        AppConstants.UI.UIStrings.Profile.SaveErrors.saveFailed
      isShowingSaveError = true
    }
  }
}

#Preview {
  ProfileView()
    .modelContainer(PreviewContainer.shared)
}
