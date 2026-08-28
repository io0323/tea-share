import SwiftUI
import SwiftData

/*
 ユーザープロファイルを表示するビューです。
 */
struct ProfileView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var users: [User]
  @AppStorage(AppConstants.Storage.currentUserIdKey)
  private var currentUserId = ""
  @State private var isEditing = AppConstants.Defaults.UI.isEditing
  @State private var editedUsername = AppConstants.Defaults.State.editedUsername
  @State private var editedLocation = AppConstants.Defaults.State.editedLocation
  @State private var isShowingSaveError = AppConstants.Defaults.UI.isShowingSaveError
  @State private var saveErrorMessage = AppConstants.Defaults.State.saveErrorMessage
  @State private var selectedTab: ProfileTab = .profile

  /*
   プロファイルタブを管理する列挙型です。
   */
  enum ProfileTab: String, CaseIterable, Identifiable {
    case profile
    case myListings
    case tradeRequests

    var id: String { rawValue }

    var displayLabel: String {
      switch self {
      case .profile:
        return AppConstants.UI.UIStrings.Profile.Tabs.profile
      case .myListings:
        return AppConstants.UI.UIStrings.Profile.Tabs.myListings
      case .tradeRequests:
        return AppConstants.UI.UIStrings.Profile.Tabs.tradeRequests
      }
    }
  }

  /*
   端末内の現在ユーザーを返します。
   */
  private var currentUser: User? {
    if let user = CurrentUserManager.fetchCurrentUser(
      modelContext: modelContext,
      storedUserId: currentUserId
    ) {
      return user
    }
    return users.first
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        Picker("", selection: $selectedTab) {
          ForEach(ProfileTab.allCases) { tab in
            Text(tab.displayLabel).tag(tab)
          }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, AppConstants.UI.Padding.large)
        .padding(.top, AppConstants.UI.Padding.large)

        Group {
          switch selectedTab {
          case .profile:
            profileContent
          case .myListings:
            MyListingsView()
          case .tradeRequests:
            TradeRequestsView()
          }
        }
      }
      .navigationTitle(AppConstants.UI.Navigation.Titles.profile)
      .toolbar {
        if selectedTab == .profile {
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
      }
      .alert(AppConstants.UI.Alerts.Titles.saveError, isPresented: $isShowingSaveError) {
        Button(AppConstants.UI.Alerts.Buttons.ok, role: .cancel) {}
      } message: {
        Text(saveErrorMessage)
      }
      .task {
        bootstrapCurrentUserIfNeeded()
      }
    }
  }

  /*
   プロファイルタブのコンテンツを返します。
   */
  private var profileContent: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.card) {
        if let user = currentUser {
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
                    .accessibilityLabel("ユーザー名")
                  TextField(
                    AppConstants.UI.UIStrings.Labels.location,
                    text: $editedLocation
                  )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("場所")
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
          }
          .padding(AppConstants.UI.Padding.default)
        } else {
          Text(AppConstants.UI.UIStrings.Labels.userDataNotFound)
            .font(AppConstants.UI.Typography.Font.title)
            .foregroundColor(.gray)
        }
      }
      .padding(.vertical, AppConstants.UI.Padding.large)
    }
  }

  /*
   現在ユーザーが未登録の場合に bootstrap します。
   */
  private func bootstrapCurrentUserIfNeeded() {
    var storedId = currentUserId
    guard CurrentUserManager.fetchCurrentUser(
      modelContext: modelContext,
      storedUserId: storedId
    ) == nil else {
      return
    }
    
    if CurrentUserManager.currentOrBootstrapUser(
      modelContext: modelContext,
      storedUserId: &storedId
    ) != nil {
      currentUserId = storedId
    }
  }

  /*
   編集モードを開始します。
   */
  private func startEditing() {
    if let user = currentUser {
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
    guard let user = currentUser else {
      saveErrorMessage =
        AppConstants.UI.UIStrings.Profile.SaveErrors.userNotFound
      isShowingSaveError = true
      return
    }
    
    let trimmedUsername = editedUsername.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedLocation = editedLocation.trimmingCharacters(in: .whitespacesAndNewlines)

    let usernameValidation = ValidationHelper.validateLength(
      trimmedUsername,
      minLength: AppConstants.ValidationLimits.minUsernameLength,
      maxLength: AppConstants.ValidationLimits.maxUsernameLength
    )
 if !usernameValidation.isValid {
      saveErrorMessage = usernameValidation.message
      isShowingSaveError = true
      return
    }

    let locationValidation = ValidationHelper.validateLength(
      trimmedLocation,
      minLength: trimmedLocation.isEmpty ? nil : AppConstants.ValidationLimits.minLocationLength,
      maxLength: trimmedLocation.isEmpty ? nil : AppConstants.ValidationLimits.maxLocationLength
    )
    if !locationValidation.isValid {
      saveErrorMessage = locationValidation.message
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
