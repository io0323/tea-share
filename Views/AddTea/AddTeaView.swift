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

  @AppStorage("addtea_draft_name") private var draftName = ""
  @AppStorage("addtea_draft_brand") private var draftBrand = ""
  @AppStorage("addtea_draft_category")
  private var draftCategory = TeaCategory.greenTea.rawValue
  @AppStorage("addtea_draft_expiry")
  private var draftExpiry = Date().timeIntervalSince1970
  @AppStorage("addtea_draft_description") private var draftDescription = ""
  @AppStorage("addtea_draft_remaining") private var draftRemaining = 50
  @AppStorage("addtea_draft_location") private var draftLocation = "未設定"
  @AppStorage("addtea_draft_username") private var draftUsername = "new_user"

  @State private var pickedPhotoItem: PhotosPickerItem?
  @State private var selectedImage: UIImage?
  @State private var isShowingCamera = false
  @State private var isAnalyzingImage = false
  @State private var isSaving = false
  @State private var isShowingErrorAlert = false
  @State private var isShowingResetAlert = false
  @State private var errorMessage = ""
  @State private var hasLoadedDraft = false

  @State private var name = ""
  @State private var brand = ""
  @State private var category: TeaCategory = .greenTea
  @State private var expiryDate = Date()
  @State private var descriptionText = ""
  @State private var remainingGrams = 50
  @State private var location = "未設定"
  @State private var username = "new_user"
  private let descriptionLimit = 300

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
    }
    if trimmedLocation.isEmpty {
      messages.append("エリアは必須です。")
    }
    if expiryDate < Calendar.current.startOfDay(for: Date()) {
      messages.append("賞味期限は本日以降を選択してください。")
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
    "\(descriptionText.count)/\(descriptionLimit)"
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("画像") {
          HStack(spacing: 12) {
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
              .scaledToFit()
              .frame(maxHeight: 180)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }

          if isAnalyzingImage {
            HStack(spacing: 8) {
              ProgressView()
              Text("画像から情報を抽出中...")
                .font(.footnote)
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
          DatePicker("賞味期限", selection: $expiryDate, displayedComponents: .date)
          TextField("説明文", text: $descriptionText, axis: .vertical)
            .lineLimit(3...6)
          HStack {
            Spacer()
            Text(descriptionCountText)
              .font(.footnote)
              .foregroundStyle(
                descriptionText.count >= descriptionLimit ? .orange : .secondary
              )
          }
        }

        Section("出品者情報") {
          TextField("ユーザー名", text: $username)
          TextField("エリア", text: $location)
        }

        Section("下書き") {
          Text("入力内容は自動で下書き保存されます。")
            .font(.footnote)
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
                .font(.footnote)
                .foregroundStyle(.red)
            }
          }
        }
      }
      .navigationTitle("新規出品")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("キャンセル") { dismiss() }
            .disabled(isSaving)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("リセット", role: .destructive) {
            isShowingResetAlert = true
          }
          .disabled(isSaving)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("保存") {
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
        if newValue.count > descriptionLimit {
          descriptionText = String(newValue.prefix(descriptionLimit))
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
      .alert("保存できませんでした", isPresented: $isShowingErrorAlert) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(errorMessage)
      }
      .alert("入力内容をリセットしますか？", isPresented: $isShowingResetAlert) {
        Button("キャンセル", role: .cancel) {}
        Button("リセット", role: .destructive) {
          resetForm()
        }
      } message: {
        Text("現在の入力内容と下書きが削除されます。")
      }
      .overlay {
        if isSaving {
          ZStack {
            Color.black.opacity(0.15)
              .ignoresSafeArea()
            ProgressView("保存中...")
              .padding(14)
              .background(.regularMaterial)
              .clipShape(RoundedRectangle(cornerRadius: 10))
          }
        }
      }
    }
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
      latitude: 35.68 + Double.random(in: -0.04...0.04),
      longitude: 139.76 + Double.random(in: -0.04...0.04),
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
    name = draftName
    brand = draftBrand
    category = TeaCategory(rawValue: draftCategory) ?? .greenTea
    expiryDate = Date(timeIntervalSince1970: draftExpiry)
    descriptionText = draftDescription
    remainingGrams = draftRemaining
    location = draftLocation
    username = draftUsername
  }

  /*
   現在の入力内容を下書きとして保存します。
   */
  private func persistDraft() {
    draftName = name
    draftBrand = brand
    draftCategory = category.rawValue
    draftExpiry = expiryDate.timeIntervalSince1970
    draftDescription = descriptionText
    draftRemaining = remainingGrams
    draftLocation = location
    draftUsername = username
  }

  /*
   下書き保存内容を初期値に戻します。
   */
  private func clearDraft() {
    draftName = ""
    draftBrand = ""
    draftCategory = TeaCategory.greenTea.rawValue
    draftExpiry = Date().timeIntervalSince1970
    draftDescription = ""
    draftRemaining = 50
    draftLocation = "未設定"
    draftUsername = "new_user"
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
