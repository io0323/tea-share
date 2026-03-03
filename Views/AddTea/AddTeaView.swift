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

  @State private var pickedPhotoItem: PhotosPickerItem?
  @State private var selectedImage: UIImage?
  @State private var isShowingCamera = false

  @State private var name = ""
  @State private var brand = ""
  @State private var category: TeaCategory = .greenTea
  @State private var expiryDate = Date()
  @State private var descriptionText = ""
  @State private var remainingGrams = 50
  @State private var location = "未設定"
  @State private var username = "new_user"

  /*
   必須項目の入力状態を判定します。
   */
  private var canSave: Bool {
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  /*
   カメラ利用可否を判定します。
   */
  private var canUseCamera: Bool {
    UIImagePickerController.isSourceTypeAvailable(.camera)
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
        }

        Section("出品者情報") {
          TextField("ユーザー名", text: $username)
          TextField("エリア", text: $location)
        }
      }
      .navigationTitle("新規出品")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("キャンセル") { dismiss() }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("保存") {
            saveTeaLeaf()
          }
          .disabled(!canSave)
        }
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
    }
  }

  /*
   PhotosPickerItemからUIImageを読み込みます。
   */
  private func loadImageFromLibrary(item: PhotosPickerItem) {
    Task {
      guard let data = try? await item.loadTransferable(type: Data.self),
            let image = UIImage(data: data) else {
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
    let request = VNRecognizeTextRequest { request, _ in
      guard let observations = request.results
        as? [VNRecognizedTextObservation] else {
        applyMockSuggestion()
        return
      }
      let recognized = observations
        .compactMap { $0.topCandidates(1).first?.string }
        .joined(separator: " ")
      applySuggestedText(recognized)
    }
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
      try handler.perform([request])
    } catch {
      applyMockSuggestion()
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
    let owner = User(
      username: username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? "new_user" : username,
      location: location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? "未設定" : location
    )

    let teaLeaf = TeaLeaf(
      name: name.trimmingCharacters(in: .whitespacesAndNewlines),
      brand: brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? "不明" : brand,
      category: category,
      remainingGrams: remainingGrams,
      expiryDate: expiryDate,
      description: descriptionText,
      latitude: 35.68 + Double.random(in: -0.04...0.04),
      longitude: 139.76 + Double.random(in: -0.04...0.04),
      tradeStatus: .available,
      owner: owner
    )

    modelContext.insert(owner)
    modelContext.insert(teaLeaf)
    dismiss()
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
