import SwiftUI
import PhotosUI
import SwiftData
import Vision
import UIKit
import os.log

/*
 茶葉の新規出品フォームを提供する画面です。
 */
struct AddTeaView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @AppStorage("addtea_draft") private var draftData: Data = Data()
  
  private static let logger = Logger(subsystem: "com.teashare.app", category: "AddTeaView")

  @State private var pickedPhotoItem: PhotosPickerItem?
  @State private var selectedImage: UIImage?
  @State private var isShowingCamera = AppConstants.AppConstants.Defaults.UI.isShowingCamera
  @State private var isAnalyzingImage = AppConstants.AppConstants.Defaults.UI.isAnalyzingImage
  @State private var isSaving = AppConstants.AppConstants.Defaults.UI.isSaving
  @State private var isShowingErrorAlert = AppConstants.AppConstants.Defaults.UI.isShowingErrorAlert
  @State private var isShowingResetAlert = AppConstants.AppConstants.Defaults.UI.isShowingResetAlert
  @State private var errorMessage = AppConstants.AppConstants.Defaults.State.errorMessage
  @State private var hasLoadedDraft = AppConstants.AppConstants.Defaults.UI.hasLoadedDraft

  @State private var draftTeaLeaf: TeaLeaf?
  @State private var name = AppConstants.AppConstants.Defaults.State.name
  @State private var brand = AppConstants.AppConstants.Defaults.State.brand
  @State private var category: TeaCategory = AppConstants.AppConstants.Defaults.Selection.category
  @State private var expiryDate = Date()
  @State private var descriptionText = AppConstants.AppConstants.Defaults.State.descriptionText
  @State private var remainingGrams = AppConstants.AppConstants.Defaults.State.remainingGrams
  @State private var location = AppConstants.AppConstants.Defaults.State.location
  @State private var username = AppConstants.AppConstants.Defaults.State.username

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
    var messages: [String] = []
    
    if trimmedName.isEmpty {
      messages.append("茶葉名は必須です。")
    } else if trimmedName.count < AppConstants.ValidationLimits.minTeaNameLength {
      messages.append("茶葉名は\(AppConstants.ValidationLimits.minTeaNameLength)文字以上で入力してください。")
    } else if trimmedName.count > AppConstants.ValidationLimits.maxTeaNameLength {
      messages.append("茶葉名は\(AppConstants.ValidationLimits.maxTeaNameLength)文字以下で入力してください。")
    }
    
    if trimmedLocation.isEmpty {
      messages.append("エリアは必須です。")
    } else if trimmedLocation.count < AppConstants.ValidationLimits.minLocationLength {
      messages.append("エリアは\(AppConstants.ValidationLimits.minLocationLength)文字以上で入力してください。")
    } else if trimmedLocation.count > AppConstants.ValidationLimits.maxLocationLength {
      messages.append("エリアは\(AppConstants.ValidationLimits.maxLocationLength)文字以下で入力してください。")
    }
    
    if remainingGrams < AppConstants.ValidationLimits.minRemainingGrams {
      messages.append("残量は\(AppConstants.ValidationLimits.minRemainingGrams)g以上で入力してください。")
    } else if remainingGrams > AppConstants.ValidationLimits.maxRemainingGrams {
      messages.append("残量は\(AppConstants.ValidationLimits.maxRemainingGrams)g以下で入力してください。")
    }
    
    if expiryDate < Calendar.current.startOfDay(for: Date()) {
      messages.append("賞味期限は本日以降を選択してください。")
    }
    
    if trimmedUsername.isEmpty {
      messages.append("ユーザー名は必須です。")
    } else if trimmedUsername.count < AppConstants.ValidationLimits.minUsernameLength {
      messages.append("ユーザー名は\(AppConstants.ValidationLimits.minUsernameLength)文字以上で入力してください。")
    } else if trimmedUsername.count > AppConstants.ValidationLimits.maxUsernameLength {
      messages.append("ユーザー名は\(AppConstants.ValidationLimits.maxUsernameLength)文字以下で入力してください。")
    }
    
    return messages
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
    "\(descriptionText.count)/\(AppConstants.TextLimits.descriptionMaxLength)"
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
        Section("画像") {
          HStack(spacing: AppConstants.UI.Layout.Spacing.button) {
            PhotosPicker(
              selection: $pickedPhotoItem,
              matching: .images,
              photoLibrary: .shared()
            ) {
              Label("ライブラリから選択", systemImage: "photo")
            }

            Button {
              isShowingCamera = true
            } label: {
              Label("カメラで撮影", systemImage: "camera")
            }
            .disabled(!canUseCamera)
          }

          if let selectedImage {
            Image(uiImage: selectedImage)
              .resizable()
              .scaledToFit(AppConstants.UI.ImageScaling.scaledToFit)
              .frame(maxHeight: AppConstants.UI.Frame.imageMaxHeight)
              .clipShape(AppConstants.UI.ClipShape.roundedRectangleSheet)

            HStack(spacing: AppConstants.UI.Layout.Spacing.button) {
              Button {
                rerunImageSuggestion()
              } label: {
                Label("再抽出", systemImage: "sparkles")
              }
              .buttonStyle(AppConstants.UI.ButtonStyle.bordered)
              .disabled(isAnalyzingImage)

              Button(role: .destructive) {
                clearSelectedImage()
              } label: {
                Label("画像を削除", systemImage: "trash")
              }
              .buttonStyle(AppConstants.UI.ButtonStyle.bordered)
              .disabled(isAnalyzingImage)

              Spacer()
            }
          }

          if isAnalyzingImage {
            HStack(spacing: AppConstants.UI.Layout.Spacing.tag) {
              ProgressView()
              Text("画像から情報を抽出中...")
                .font(AppConstants.UI.Typography.Font.footnote)
                .foregroundStyle(.secondary)
            }
          }
        }

        Section("茶葉情報") {
          TextField("茶葉名", text: $name)
          TextField("ブランド名", text: $brand)
          Picker("カテゴリー", selection: $category) {
            ForEach(TeaCategory.allCases) { category in
              Text(category.rawValue).tag(category)
            }
          }
          Stepper(
            "残量: \(remainingGrams)g",
            value: $remainingGrams,
            in: 5...500,
            step: 5
          )
          quickRemainingButtons

          DatePicker("賞味期限", selection: $expiryDate, displayedComponents: .date)
          expiryPresetButtons

          TextField("説明文", text: $descriptionText, axis: .vertical)
            .lineLimit(3...6)
          HStack {
            Spacer()
              Text(descriptionCountText)
              .font(AppConstants.UI.Typography.Font.footnote)
              .foregroundStyle(
                descriptionText.count >= AppConstants.TextLimits.descriptionMaxLength ? .orange : .secondary
              )
          }
        }

        Section("出品者情報") {
          TextField("ユーザー名", text: $username)
          TextField("エリア", text: $location)
        }

        Section("下書き") {
            Text("入力内容は自動で下書き保存されます。")
            .font(AppConstants.UI.Typography.Font.footnote)
            .foregroundStyle(.secondary)
          Button("入力内容をリセット", role: .destructive) {
            isShowingResetAlert = true
          }
          .disabled(isSaving)
        }

        if !validationMessages.isEmpty {
          Section("入力チェック") {
            ForEach(validationMessages, id: \.self) { message in
              Text(message)
                .font(AppConstants.UI.Typography.Font.footnote)
                .foregroundStyle(.red)
            }
          }
        }
      }
      .navigationTitle(AppConstants.UI.Navigation.Titles.addTea)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(AppConstants.UI.Navigation.Toolbar.Buttons.cancel) { dismiss() }
            .disabled(isSaving)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button(AppConstants.UI.UIStrings.Actions.reset, role: .destructive) {
            isShowingResetAlert = true
          }
          .disabled(isSaving)
        }
        ToolbarItem(placement: .topBarTrailing) {
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
        Button(AppConstants.UI.Alerts.Buttons.ok, role: .cancel) {}
      } message: {
        Text(errorMessage)
      }
      .alert(AppConstants.UI.Alerts.Titles.resetInput, isPresented: $isShowingResetAlert) {
        Button(AppConstants.UI.Alerts.Buttons.cancel, role: .cancel) {}
        Button(AppConstants.UI.Alerts.Buttons.reset, role: .destructive) {
          resetForm()
        }
      } message: {
        Text(AppConstants.UI.Alerts.Messages.resetConfirmation)
      }
      .overlay {
        if isSaving {
          ZStack {
            Color.black.opacity(AppConstants.UI.Opacity.blackOverlay)
              .ignoresSafeArea()
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
      Text("クイック")
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
      Text("期限プリセット")
        .font(AppConstants.UI.Typography.Font.caption)
        .foregroundStyle(.secondary)
      ForEach(ExpiryPreset.allCases) { preset in
        Button(preset.rawValue) {
          applyExpiryPreset(preset)
        }
        .font(.caption.weight(.semibold))
        .buttonStyle(AppConstants.UI.ButtonStyle.bordered)
      }
      Spacer()
    }
  }

  /*
   指定gに残量を更新するボタンを返します。
   */
  private func quickAmountButton(_ grams: Int) -> some View {
    Button("\(grams)g") {
      remainingGrams = grams
    }
    .font(.caption.weight(.semibold))
    .buttonStyle(AppConstants.UI.ButtonStyle.bordered)
  }

  /*
   PhotosPickerItemからUIImageを読み込みます。
   */
  private func loadImageFromLibrary(item: PhotosPickerItem) {
    Task {
      guard let data = try? await item.loadTransferable(type: Data.self),
            let image = UIImage(data: data) else {
        await MainActor.run {
          presentError("画像の読み込みに失敗しました。別の画像を選択してください。")
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
    guard let cgImage = image.cgImage else { return }
    isAnalyzingImage = true
    let request = VNRecognizeTextRequest { request, _ in
      guard let observations = request.results
        as? [VNRecognizedTextObservation] else {
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
    let tokens = text
      .components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }
    guard !tokens.isEmpty else {
      applyMockSuggestion()
      return
    }

    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      name = tokens.prefix(2).joined(separator: " ")
    }
    if brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      brand = tokens.dropFirst(2).prefix(2).joined(separator: " ")
      if brand.isEmpty {
        brand = "ブランド不明"
      }
    }
  }

  /*
   Visionが使えないケース向けの簡易補完を適用します。
   */
  private func applyMockSuggestion() {
    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      name = "抽出候補: お茶"
    }
    if brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      brand = "抽出候補: TeaBrand"
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

    let owner = User(
      username: trimmedUsername.isEmpty ? "new_user" : trimmedUsername,
      location: trimmedLocation
    )

    let teaLeaf = TeaLeaf(
      name: trimmedName,
      brand: trimmedBrand.isEmpty ? "不明" : trimmedBrand,
      category: category,
      remainingGrams: remainingGrams,
      expiryDate: expiryDate,
      description: trimmedDescription,
      latitude: AppConstants.Location.defaultLatitude + Double.random(in: AppConstants.Location.randomLatitudeRange),
      longitude: AppConstants.Location.defaultLongitude + Double.random(in: AppConstants.Location.randomLongitudeRange),
      tradeStatus: .available,
      owner: owner
    )

    do {
      modelContext.insert(owner)
      modelContext.insert(teaLeaf)
      try modelContext.save()
      clearDraft()
      dismiss()
    } catch {
      isSaving = false
      presentError("保存処理に失敗しました。時間をおいて再度お試しください。")
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
      location = draftTeaLeaf?.owner?.location ?? "未設定"
      username = draftTeaLeaf?.owner?.username ?? "new_user"
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
      username: trimmedUsername.isEmpty ? "new_user" : trimmedUsername,
      location: trimmedLocation
    )
    
    draftTeaLeaf = TeaLeaf(
      name: trimmedName,
      brand: trimmedBrand.isEmpty ? "不明" : trimmedBrand,
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
    location = "未設定"
    username = "new_user"
    selectedImage = nil
    pickedPhotoItem = nil
    clearDraft()
  }

  /*
   賞味期限プリセットを適用します。
   */
  private func applyExpiryPreset(_ preset: ExpiryPreset) {
    let today = Calendar.current.startOfDay(for: Date())
    expiryDate = Calendar.current.date(
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
