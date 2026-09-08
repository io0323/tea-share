import SwiftUI
import PhotosUI
import SwiftData
import Vision
import UIKit

/*
 茶葉の新規出品フォームを提供する画面です。
 */
struct AddTeaView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @AppStorage("addtea_draft") private var draftData: Data = Data()
  @AppStorage(AppConstants.Storage.currentUserIdKey)
  private var currentUserId = ""
  
  private static let logger = Logger(subsystem: "com.teashare.app", category: "AddTeaView")

  @State private var pickedPhotoItem: PhotosPickerItem?
  @State private var selectedImage: UIImage?
  @State private var isShowingCamera = AppConstants.Defaults.UI.isShowingCamera
  @State private var isAnalyzingImage = AppConstants.Defaults.UI.isAnalyzingImage
  @State private var isSaving = AppConstants.Defaults.UI.isSaving
  @State private var isShowingErrorAlert = AppConstants.Defaults.UI.isShowingErrorAlert
  @State private var isShowingResetAlert = AppConstants.Defaults.UI.isShowingResetAlert
  @State private var errorMessage = AppConstants.Defaults.State.errorMessage
  @State private var hasLoadedDraft = AppConstants.Defaults.UI.hasLoadedDraft

  @State private var draftTeaLeaf: TeaLeaf?
  @State private var name = AppConstants.Defaults.State.name
  @State private var brand = AppConstants.Defaults.State.brand
  @State private var category: TeaCategory = AppConstants.Defaults.Selection.category
  @State private var expiryDate = Date()
  @State private var descriptionText = AppConstants.Defaults.State.descriptionText
  @State private var remainingGrams = AppConstants.Defaults.State.remainingGrams
  @State private var location = AppConstants.Defaults.State.location
  @State private var username = AppConstants.Defaults.State.username

  /*
   必須項目の入力状態を判定します。
   */
  private var canSave: Bool {
    validationMessages.isEmpty && !isSaving
  }

  /*
   カメラ利用可否を判定します。
   */
  private var canUseCamera: Bool {
    UIImagePickerController.isSourceTypeAvailable(.camera)
  }

  /*
   保存前に表示する入力チェックメッセージを返します。
   */
  private var validationMessages: [String] {
    var results: [(isValid: Bool, message: String?)] = []
    
    let nameValidation = ValidationHelper.validateLength(
      trimmedName,
      minLength: AppConstants.ValidationLimits.minTeaNameLength,
      maxLength: AppConstants.ValidationLimits.maxTeaNameLength
    )
    results.append(nameValidation)
    
    let locationValidation = ValidationHelper.validateLength(
      trimmedLocation,
      minLength: AppConstants.ValidationLimits.minLocationLength,
      maxLength: AppConstants.ValidationLimits.maxLocationLength
    )
    results.append(locationValidation)
    
    let gramsValidation = ValidationHelper.validateRange(
      remainingGrams,
      minValue: AppConstants.ValidationLimits.minRemainingGrams,
      maxValue: AppConstants.ValidationLimits.maxRemainingGrams
    )
    results.append(gramsValidation)
    
    let dateValidation = ValidationHelper.validateNotPast(expiryDate)
    results.append(dateValidation)
    
    let usernameValidation = ValidationHelper.validateLength(
      trimmedUsername,
      minLength: AppConstants.ValidationLimits.minUsernameLength,
      maxLength: AppConstants.ValidationLimits.maxUsernameLength
    )
    results.append(usernameValidation)
    
    let combined = ValidationHelper.combineResults(results)
    return combined.messages
  }

  /*
   前後空白を除いた茶葉名を返します。
   */
  private var trimmedName: String {
    name.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /*
   前後空白を除いたブランド名を返します。
   */
  private var trimmedBrand: String {
    brand.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /*
   前後空白を除いたユーザー名を返します。
   */
  private var trimmedUsername: String {
    username.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /*
   前後空白を除いたエリア名を返します。
   */
  private var trimmedLocation: String {
    location.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /*
   前後空白を除いた説明文を返します。
   */
  private var trimmedDescription: String {
    descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /*
   説明文の文字数カウンター表示文言を返します。
   */
  private var descriptionCountText: String {
    StringFormatter.format(
      StringFormatter.format(
        AppConstants.UI.UIStrings.Labels.characterCount,
        key: "count",
        value: descriptionText.count
      ),
      key: "max",
      value: AppConstants.TextLimits.descriptionMaxLength
    )
  }

  /*
   賞味期限のクイック選択を管理する列挙型です。
   */
  private enum ExpiryPreset: String, CaseIterable, Identifiable {
    case oneMonth = "1か月"
    case threeMonths = "3か月"
    case sixMonths = "6か月"

    var id: String { rawValue }

    /*
     現在日付から加算する月数を返します。
     */
    var monthOffset: Int {
      switch self {
      case .oneMonth:
        return 1
      case .threeMonths:
        return 3
      case .sixMonths:
        return 6
      }
    }
  }

  var body: some View {
    NavigationStack {
      Form {
        Section(AppConstants.UI.UIStrings.AddTea.Sections.image) {
          HStack(spacing: AppConstants.UI.Layout.Spacing.button) {
            PhotosPicker(
              selection: $pickedPhotoItem,
              matching: .images,
              photoLibrary: .shared()
            ) {
              Label(
                AppConstants.UI.UIStrings.AddTea.Actions.pickFromLibrary,
                systemImage: AppConstants.UI.UIStrings.Content.photo
              )
            }

            Button {
              isShowingCamera = true
            } label: {
              Label(
                AppConstants.UI.UIStrings.AddTea.Actions.takePhoto,
                systemImage: AppConstants.UI.UIStrings.Content.camera
              )
            }
            .disabled(!canUseCamera)
          }

          if let selectedImage {
            Image(uiImage: selectedImage)
              .resizable()
              .aspectRatio(
                contentMode: AppConstants.UI.ImageScaling.scaledToFit
              )
              .frame(maxHeight: AppConstants.UI.Frame.imageMaxHeight)
              .clipShape(AppConstants.UI.ClipShape.roundedRectangleSheet)

            HStack(spacing: AppConstants.UI.Layout.Spacing.button) {
              Button {
                rerunImageSuggestion()
              } label: {
                Label(
                  AppConstants.UI.UIStrings.AddTea.Actions.reanalyze,
                  systemImage: AppConstants.UI.UIStrings.Content.sparkles
                )
              }
              .buttonStyle(AppConstants.UI.ButtonStyle.bordered)
              .disabled(isAnalyzingImage)

              Button(role: AppConstants.UI.ButtonRole.destructive) {
                clearSelectedImage()
              } label: {
                Label(
                  AppConstants.UI.UIStrings.AddTea.Actions.removeImage,
                  systemImage: AppConstants.UI.UIStrings.Content.trash
                )
              }
              .buttonStyle(AppConstants.UI.ButtonStyle.bordered)
              .disabled(isAnalyzingImage)

              Spacer()
            }
          }

          if isAnalyzingImage {
            HStack(spacing: AppConstants.UI.Layout.Spacing.tag) {
              ProgressView()
              Text(AppConstants.UI.UIStrings.AddTea.Hints.analyzingImage)
                .font(AppConstants.UI.Typography.Font.footnote)
                .foregroundStyle(.secondary)
            }
          }
        }

        Section(AppConstants.UI.UIStrings.AddTea.Sections.tea) {
          TextField(
            AppConstants.UI.UIStrings.AddTea.FormFields.name,
            text: $name
          )
          .accessibilityLabel("茶葉名")
          TextField(
            AppConstants.UI.UIStrings.AddTea.FormFields.brand,
            text: $brand
          )
          .accessibilityLabel("ブランド")
          Picker(
            AppConstants.UI.UIStrings.AddTea.FormFields.category,
            selection: $category
          ) {
            ForEach(TeaCategory.allCases) { category in
              Text(category.rawValue).tag(category)
            }
          }
          .accessibilityLabel("カテゴリ")
          Stepper(
            StringFormatter.format(AppConstants.UI.UIStrings.AddTea.FormFields.remaining, key: "grams", value: remainingGrams),
            value: $remainingGrams,
            in: 5...500,
            step: 5
          )
          .accessibilityLabel("残量")
          .accessibilityValue("\(remainingGrams)グラム")
          quickRemainingButtons

          DatePicker(
            AppConstants.UI.UIStrings.AddTea.FormFields.expiry,
            selection: $expiryDate,
            displayedComponents: AppConstants.UI.DatePickerSettings.dateComponents
          )
          .accessibilityLabel("賞味期限")
          expiryPresetButtons

          TextField(
            AppConstants.UI.UIStrings.AddTea.FormFields.description,
            text: $descriptionText,
            axis: AppConstants.UI.TextFieldAxis.vertical
          )
            .lineLimit(AppConstants.UI.LineLimit.description)
            .accessibilityLabel("説明")
          HStack {
            Spacer()
              Text(descriptionCountText)
              .font(AppConstants.UI.Typography.Font.footnote)
              .foregroundStyle(
                descriptionText.count >= AppConstants.TextLimits.descriptionMaxLength ? AppConstants.UI.BasicColor.orange : .secondary
              )
              .accessibilityLabel("文字数")
          }
        }

        Section(AppConstants.UI.UIStrings.AddTea.Sections.seller) {
          TextField(
            AppConstants.UI.UIStrings.AddTea.FormFields.username,
            text: $username
          )
          .accessibilityLabel("ユーザー名")
          TextField(
            AppConstants.UI.UIStrings.AddTea.FormFields.area,
            text: $location
          )
          .accessibilityLabel("場所")
        }

        Section(AppConstants.UI.UIStrings.AddTea.Sections.draft) {
            Text(AppConstants.UI.UIStrings.AddTea.Hints.autoDraft)
            .font(AppConstants.UI.Typography.Font.footnote)
            .foregroundStyle(.secondary)
          Button(
            AppConstants.UI.UIStrings.AddTea.Actions.resetForm,
            role: AppConstants.UI.ButtonRole.destructive
          ) {
            isShowingResetAlert = true
          }
          .disabled(isSaving)
        }

        if !validationMessages.isEmpty {
          Section(AppConstants.UI.UIStrings.AddTea.Sections.validation) {
            ForEach(validationMessages, id: \.self) { message in
              Text(message)
                .font(AppConstants.UI.Typography.Font.footnote)
                .foregroundStyle(AppConstants.UI.BasicColor.red)
            }
          }
        }
      }
      .navigationTitle(AppConstants.UI.Navigation.Titles.addTea)
      .toolbar {
        ToolbarItem(placement: AppConstants.UI.ToolbarPlacement.topBarLeading) {
          Button(AppConstants.UI.Navigation.Toolbar.Buttons.cancel) { dismiss() }
            .disabled(isSaving)
        }
        ToolbarItem(placement: AppConstants.UI.ToolbarPlacement.topBarTrailing) {
          Button(AppConstants.UI.UIStrings.Actions.reset, role: AppConstants.UI.ButtonRole.destructive) {
            isShowingResetAlert = true
          }
          .disabled(isSaving)
        }
        ToolbarItem(placement: AppConstants.UI.ToolbarPlacement.topBarTrailing) {
          Button(AppConstants.UI.Navigation.Toolbar.Buttons.save) {
            saveTeaLeaf()
          }
          .disabled(!canSave)
        }
      }
      .onAppear {
        loadDraftIfNeeded()
      }
      .onChange(of: pickedPhotoItem) { _, newValue in
        guard let newValue else { return }
        loadImageFromLibrary(item: newValue)
      }
      .sheet(isPresented: $isShowingCamera) {
        CameraPicker(image: $selectedImage)
      }
      .onChange(of: selectedImage) { _, newImage in
        guard let newImage else { return }
        suggestTeaInfo(image: newImage)
      }
      .onChange(of: descriptionText) { _, newValue in
        if newValue.count > AppConstants.TextLimits.descriptionMaxLength {
          descriptionText = String(newValue.prefix(AppConstants.TextLimits.descriptionMaxLength))
        }
        persistDraft()
      }
      .onChange(of: name) { _, _ in persistDraft() }
      .onChange(of: brand) { _, _ in persistDraft() }
      .onChange(of: category) { _, _ in persistDraft() }
      .onChange(of: expiryDate) { _, _ in persistDraft() }
      .onChange(of: remainingGrams) { _, _ in persistDraft() }
      .onChange(of: location) { _, _ in persistDraft() }
      .onChange(of: username) { _, _ in persistDraft() }
      .alert(AppConstants.UI.Alerts.Titles.saveFailed, isPresented: $isShowingErrorAlert) {
        Button(AppConstants.UI.Alerts.Buttons.ok, role: AppConstants.UI.ButtonRole.cancel) {}
      } message: {
        Text(errorMessage)
      }
      .alert(AppConstants.UI.Alerts.Titles.resetInput, isPresented: $isShowingResetAlert) {
        Button(AppConstants.UI.Alerts.Buttons.cancel, role: AppConstants.UI.ButtonRole.cancel) {}
        Button(AppConstants.UI.Alerts.Buttons.reset, role: AppConstants.UI.ButtonRole.destructive) {
          resetForm()
        }
      } message: {
        Text(AppConstants.UI.Alerts.Messages.resetConfirmation)
      }
      .overlay {
        if isSaving {
          ZStack {
            Color.black.opacity(AppConstants.UI.Opacity.blackOverlay)
              .ignoresSafeArea(AppConstants.UI.SafeAreaSettings.ignoresSafeArea ? .all : [])
            ProgressView(AppConstants.UI.UIStrings.Actions.saving)
              .padding(AppConstants.UI.Padding.large)
              .background(.regularMaterial)
              .clipShape(AppConstants.UI.ClipShape.roundedRectangleProgress)
          }
        }
      }
    }
  }

  /*
   残量のクイック入力ボタン群を返します。
   */
  private var quickRemainingButtons: some View {
    HStack(spacing: AppConstants.UI.Layout.Spacing.tag) {
      Text(AppConstants.UI.UIStrings.AddTea.Actions.quickRemaining)
        .font(AppConstants.UI.Typography.Font.caption)
        .foregroundStyle(.secondary)
      quickAmountButton(25)
      quickAmountButton(50)
      quickAmountButton(100)
      Spacer()
    }
  }

  /*
   賞味期限のクイック入力ボタン群を返します。
   */
  private var expiryPresetButtons: some View {
    HStack(spacing: AppConstants.UI.Layout.Spacing.tag) {
      Text(AppConstants.UI.UIStrings.AddTea.Actions.expiryPreset)
        .font(AppConstants.UI.Typography.Font.caption)
        .foregroundStyle(.secondary)
      ForEach(ExpiryPreset.allCases) { preset in
        Button(preset.rawValue) {
          applyExpiryPreset(preset)
        }
        .font(AppConstants.UI.Typography.Font.caption.weight(AppConstants.UI.Typography.FontWeight.semibold))
        .buttonStyle(AppConstants.UI.ButtonStyle.bordered)
      }
      Spacer()
    }
  }

  /*
   指定gに残量を更新するボタンを返します。
   */
  private func quickAmountButton(_ grams: Int) -> some View {
    Button(
      StringFormatter.format(AppConstants.UI.UIStrings.AddTea.Actions.quickGrams, key: "grams", value: grams)
    ) {
      remainingGrams = grams
    }
    .font(AppConstants.UI.Typography.Font.caption.weight(AppConstants.UI.Typography.FontWeight.semibold))
    .buttonStyle(AppConstants.UI.ButtonStyle.bordered)
  }

  /*
   PhotosPickerItemからUIImageを読み込みます。
   */
  private func loadImageFromLibrary(item: PhotosPickerItem) {
    Task {
      guard let data = try? await item.loadTransferable(type: Data.self) else {
        await MainActor.run {
          presentError(AppConstants.UI.UIStrings.AddTea.Errors.imageLoadFailed)
        }
        return
      }
      
      guard let image = UIImage(data: data) else {
        await MainActor.run {
          presentError(AppConstants.UI.UIStrings.AddTea.Errors.imageLoadFailed)
        }
        return
      }
      
      await MainActor.run {
        selectedImage = image
      }
    }
  }

  /*
   画像解析で茶葉名とブランド候補を補完します。
   */
  private func suggestTeaInfo(image: UIImage) {
    guard let cgImage = image.cgImage else {
      Task { @MainActor in
        applyMockSuggestion()
        isAnalyzingImage = false
      }
      return
    }
    
    isAnalyzingImage = true
    let request = VNRecognizeTextRequest { request, _ in
      guard let observations = request.results as? [VNRecognizedTextObservation] else {
        Task { @MainActor in
          applyMockSuggestion()
          isAnalyzingImage = false
        }
        return
      }
      let recognized = observations
        .compactMap { $0.topCandidates(1).first?.string }
        .joined(separator: " ")
      Task { @MainActor in
        applySuggestedText(recognized)
        isAnalyzingImage = false
      }
    }
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
      try handler.perform([request])
    } catch {
      applyMockSuggestion()
      isAnalyzingImage = false
    }
  }

  /*
   抽出した文字列から茶葉名とブランド名を推定します。
   */
  private func applySuggestedText(_ text: String) {
    let whitespaceSet = CharacterSet.whitespacesAndNewlines
    let tokens = text
      .components(separatedBy: whitespaceSet)
      .filter { !$0.isEmpty }
    guard !tokens.isEmpty else {
      applyMockSuggestion()
      return
    }

    if name.trimmingCharacters(in: whitespaceSet).isEmpty {
      name = tokens.prefix(2).joined(separator: " ")
    }
    if brand.trimmingCharacters(in: whitespaceSet).isEmpty {
      brand = tokens.dropFirst(2).prefix(2).joined(separator: " ")
      if brand.isEmpty {
        brand = AppConstants.UI.UIStrings.AddTea.Suggestions.unknownBrand
      }
    }
  }

  /*
   Visionが使えないケース向けの簡易補完を適用します。
   */
  private func applyMockSuggestion() {
    let whitespaceSet = CharacterSet.whitespacesAndNewlines
    if name.trimmingCharacters(in: whitespaceSet).isEmpty {
      name = AppConstants.UI.UIStrings.AddTea.Suggestions.mockTeaName
    }
    if brand.trimmingCharacters(in: whitespaceSet).isEmpty {
      brand = AppConstants.UI.UIStrings.AddTea.Suggestions.mockBrand
    }
  }

  /*
   入力値からTeaLeafを作成して保存します。
   */
  private func saveTeaLeaf() {
    guard validationMessages.isEmpty else {
      presentError(validationMessages.joined(separator: "\n"))
      return
    }
    isSaving = true

    var storedUserId = currentUserId
    let resolvedOwner = CurrentUserManager.resolveOwner(
      modelContext: modelContext,
      storedUserId: &storedUserId,
      username: trimmedUsername.isEmpty
        ? AppConstants.Defaults.State.username
        : trimmedUsername,
      location: trimmedLocation
    )
    currentUserId = storedUserId
    let owner = resolvedOwner.user

    let teaLeafId = UUID()
    var imagePath = ""
    if let selectedImage {
      do {
        imagePath = try TeaImageStorage.saveImage(
          selectedImage,
          teaLeafId: teaLeafId
        )
      } catch {
        isSaving = false
        presentError(
          AppConstants.UI.UIStrings.AddTea.Errors.imageSaveFailed
        )
        return
      }
    }

    let teaLeaf = TeaLeaf(
      id: teaLeafId,
      name: trimmedName,
      brand: trimmedBrand.isEmpty
        ? AppConstants.UI.UIStrings.Placeholders.unknown
        : trimmedBrand,
      category: category,
      remainingGrams: remainingGrams,
      expiryDate: expiryDate,
      imagePath: imagePath,
      description: trimmedDescription,
      latitude: AppConstants.Location.defaultLatitude + Double.random(in: AppConstants.Location.randomLatitudeRange),
      longitude: AppConstants.Location.defaultLongitude + Double.random(in: AppConstants.Location.randomLongitudeRange),
      tradeStatus: .available,
      owner: owner
    )

    do {
      if resolvedOwner.isNew {
        modelContext.insert(owner)
      }
      modelContext.insert(teaLeaf)
      try modelContext.save()
      clearDraft()
      dismiss()
    } catch {
      isSaving = false
      presentError(AppConstants.UI.UIStrings.AddTea.Errors.saveFailed)
    }
  }

  /*
   既存の下書き内容をフォームに反映します。
   */
  private func loadDraftIfNeeded() {
    guard !hasLoadedDraft else { return }
    hasLoadedDraft = true
    
    guard !draftData.isEmpty else { return }
    
    do {
      draftTeaLeaf = try JSONDecoder().decode(TeaLeaf.self, from: draftData)
      name = draftTeaLeaf?.name ?? ""
      brand = draftTeaLeaf?.brand ?? ""
      category = draftTeaLeaf?.category ?? .greenTea
      expiryDate = draftTeaLeaf?.expiryDate ?? Date()
      descriptionText = draftTeaLeaf?.description ?? ""
      remainingGrams = draftTeaLeaf?.remainingGrams ?? 50
      location = draftTeaLeaf?.owner?.location
        ?? AppConstants.UI.UIStrings.Placeholders.notSet
      username = draftTeaLeaf?.owner?.username
        ?? AppConstants.Defaults.State.username
    } catch {
      Self.logger.error("Failed to load draft: \(error.localizedDescription)")
      clearDraft()
    }
  }

  /*
   現在の入力内容を下書きとして保存します。
   */
  private func persistDraft() {
    let draftOwner = User(
      username: trimmedUsername.isEmpty
        ? AppConstants.Defaults.State.username
        : trimmedUsername,
      location: trimmedLocation
    )
    
    draftTeaLeaf = TeaLeaf(
      name: trimmedName,
      brand: trimmedBrand.isEmpty
        ? AppConstants.UI.UIStrings.Placeholders.unknown
        : trimmedBrand,
      category: category,
      remainingGrams: remainingGrams,
      expiryDate: expiryDate,
      description: trimmedDescription,
      latitude: AppConstants.Location.defaultLatitude,
      longitude: AppConstants.Location.defaultLongitude,
      tradeStatus: .available,
      owner: draftOwner
    )
    
    do {
      draftData = try JSONEncoder().encode(draftTeaLeaf)
    } catch {
      Self.logger.error("Failed to save draft: \(error.localizedDescription)")
    }
  }

  /*
   下書き保存内容を初期値に戻します。
   */
  private func clearDraft() {
    draftData = Data()
    draftTeaLeaf = nil
  }

  /*
   フォーム状態と下書き内容を同時に初期化します。
   */
  private func resetForm() {
    name = ""
    brand = ""
    category = .greenTea
    expiryDate = Date()
    descriptionText = ""
    remainingGrams = 50
    location = AppConstants.UI.UIStrings.Placeholders.notSet
    username = AppConstants.Defaults.State.username
    selectedImage = nil
    pickedPhotoItem = nil
    clearDraft()
  }

  /*
   賞味期限プリセットを適用します。
   */
  private func applyExpiryPreset(_ preset: ExpiryPreset) {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    expiryDate = calendar.date(
      byAdding: .month,
      value: preset.monthOffset,
      to: today
    ) ?? today
  }

  /*
   現在の画像で情報抽出を再実行します。
   */
  private func rerunImageSuggestion() {
    guard let selectedImage else { return }
    suggestTeaInfo(image: selectedImage)
  }

  /*
   選択済み画像をフォームから取り除きます。
   */
  private func clearSelectedImage() {
    selectedImage = nil
    pickedPhotoItem = nil
  }

  /*
   エラー表示用のアラート状態を更新します。
   */
  private func presentError(_ message: String) {
    errorMessage = message
    isShowingErrorAlert = true
  }
}

/*
 UIKitカメラをSwiftUIで利用するためのラッパーです。
 */
private struct CameraPicker: UIViewControllerRepresentable {
  @Binding var image: UIImage?
  @Environment(\.dismiss) private var dismiss

  /*
   UIImagePickerControllerを生成します。
   */
  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = .camera
    picker.delegate = context.coordinator
    return picker
  }

  /*
   UIViewControllerの更新処理です。
   */
  func updateUIViewController(
    _ uiViewController: UIImagePickerController,
    context: Context
  ) {}

  /*
   Coordinatorを生成します。
   */
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  /*
   UIImagePickerControllerのデリゲートを扱うクラスです。
   */
  final class Coordinator: NSObject,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {
    let parent: CameraPicker

    init(_ parent: CameraPicker) {
      self.parent = parent
    }

    /*
     撮影または選択した画像を取得します。
     */
    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      parent.image = info[.originalImage] as? UIImage
      parent.dismiss()
    }

    /*
     キャンセル時にピッカーを閉じます。
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.dismiss()
    }
  }
}

#Preview {
  AddTeaView()
    .modelContainer(PreviewContainer.shared)
}
