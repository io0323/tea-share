import SwiftUI
import SwiftData
import MapKit

/*
 茶葉カードから遷移する詳細画面です。
 */
struct TeaLeafDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Bindable var teaLeaf: TeaLeaf
  @State private var isEditingDetail = false
  @State private var editableRemainingGrams = 0
  @State private var editableExpiryDate = Date()
  @State private var editableDescription = ""
  @State private var isShowingSaveError = false
  @State private var saveErrorMessage = ""
  @State private var isShowingTradeRequestAlert = false
  @State private var tradeRequestMessage = ""
  @Query private var users: [User]

  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
  }()

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        if !teaLeaf.imagePath.isEmpty {
          imageSection
        }
        headerCard
        statusSection
        quickStatusSection
        tradeRequestSection
        detailSection
      }
      .padding(16)
    }
    .navigationTitle(AppConstants.UI.Navigation.Titles.teaDetail)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(isEditingDetail ? AppConstants.UI.Navigation.Toolbar.Buttons.done : AppConstants.UI.Navigation.Toolbar.Buttons.edit) {
          if isEditingDetail {
            commitDetailEdits()
          } else {
            startEditingDetail()
          }
        }
      }
      if isEditingDetail {
        ToolbarItem(placement: .topBarLeading) {
          Button(AppConstants.UI.Navigation.Toolbar.Buttons.cancel, role: .cancel) {
            cancelEditingDetail()
          }
        }
      }
    }
    .alert(AppConstants.UI.Alerts.Titles.saveError, isPresented: $isShowingSaveError) {
      Button(AppConstants.UI.Alerts.Buttons.ok, role: .cancel) {}
    } message: {
      Text(saveErrorMessage)
    }
    .alert(AppConstants.UI.Alerts.Titles.tradeRequest, isPresented: $isShowingTradeRequestAlert) {
      Button(AppConstants.UI.Alerts.Buttons.ok, role: .cancel) {}
    } message: {
      Text(tradeRequestMessage)
    }
    .onChange(of: editableDescription) { _, newValue in
      if newValue.count > AppConstants.TextLimits.descriptionMaxLength {
        editableDescription = String(newValue.prefix(AppConstants.TextLimits.descriptionMaxLength))
      }
    }
  }

  /*
   主要情報をまとめたヘッダーカードを返します。
   */
  private var headerCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(teaLeaf.name)
        .font(AppConstants.UI.Typography.FontScale.detailTitle)
      Text(teaLeaf.brand)
        .font(AppConstants.UI.Typography.FontScale.detailSubtitle)
        .foregroundStyle(.secondary)

      HStack(spacing: 8) {
        tagLabel(teaLeaf.category.rawValue, tint: .green)
        tagLabel(teaLeaf.tradeStatus.rawValue, tint: statusColor)
      }
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(AppConstants.UI.Opacity.whiteCard))
    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.extraLarge))
    .shadow(color: .black.opacity(AppConstants.UI.Opacity.blackLight), radius: 8, x: 0, y: 3)
  }

  /*
   取引状態を変更するセクションを返します。
   */
  private var statusSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("取引ステータス")
        .font(AppConstants.UI.Typography.FontScale.sectionTitle)

      Picker("取引ステータス", selection: $teaLeaf.tradeStatus) {
        ForEach(TradeStatus.allCases) { status in
          Text(status.rawValue).tag(status)
        }
      }
      .pickerStyle(.segmented)
      .onChange(of: teaLeaf.tradeStatus) { _, _ in
        saveContext()
      }
    }
    .padding(AppConstants.UI.Padding.large)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(AppConstants.UI.Opacity.whiteCard))
    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.extraLarge))
  }

  /*
   ワンタップで次ステータスへ進めるセクションを返します。
   */
  private var quickStatusSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("クイック操作")
        .font(AppConstants.UI.Typography.FontScale.sectionTitle)

      Button {
        guard let nextStatus else { return }
        teaLeaf.tradeStatus = nextStatus
        saveContext()
      } label: {
        HStack {
          Image(systemName: AppConstants.UI.UIStrings.Content.arrowRightCircleFill)
          Text(quickActionTitle)
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .disabled(nextStatus == nil)
    }
    .padding(AppConstants.UI.Padding.large)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(AppConstants.UI.Opacity.whiteCard))
    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.extraLarge))
  }

  /*
   残量や期限などの詳細情報を返します。
   */
  private var detailSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("詳細情報")
          .font(AppConstants.UI.Typography.FontScale.sectionTitle)
        Spacer()
        if isEditingDetail {
          Text("\(editableDescription.count)/\(AppConstants.TextLimits.descriptionMaxLength)")
            .font(.footnote)
            .foregroundStyle(
              editableDescription.count >= AppConstants.TextLimits.descriptionMaxLength
                ? .orange
                : .secondary
            )
        }
      }

      if isEditingDetail {
        Stepper(
          "残量: \(editableRemainingGrams)g",
          value: $editableRemainingGrams,
          in: AppConstants.ValidationLimits.minRemainingGrams...AppConstants.ValidationLimits.maxRemainingGrams,
          step: 5
        )
        .disabled(true)
        DatePicker(
          "賞味期限",
          selection: $editableExpiryDate,
          displayedComponents: .date
        )
        TextField("説明", text: $editableDescription, axis: .vertical)
          .lineLimit(3...8)
      } else {
        detailRow("残量", value: "\(teaLeaf.remainingGrams)g")
        detailRow("賞味期限", value: dateFormatter.string(from: teaLeaf.expiryDate))
        detailRow("出品者", value: teaLeaf.owner?.username ?? "未設定")
        detailRow("エリア", value: teaLeaf.owner?.location ?? "未設定")
        detailRow("緯度", value: String(format: "%.5f", teaLeaf.latitude))
        detailRow("経度", value: String(format: "%.5f", teaLeaf.longitude))

        Button {
          openInMaps()
        } label: {
          HStack {
            Image(systemName: AppConstants.UI.UIStrings.Content.mapFill)
            Text(AppConstants.UI.UIStrings.Actions.openInMap)
              .fontWeight(.semibold)
          }
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)

        VStack(alignment: .leading, spacing: 6) {
          Text(AppConstants.UI.UIStrings.Labels.description)
            .font(AppConstants.UI.Typography.FontScale.sectionSubtitle)
          Text(teaLeaf.description.isEmpty ? AppConstants.UI.UIStrings.Placeholders.descriptionEmpty : teaLeaf.description)
            .font(AppConstants.UI.Typography.FontScale.detailBody)
            .foregroundStyle(.secondary)
        }
      }
    }
    .padding(AppConstants.UI.Padding.large)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(AppConstants.UI.Opacity.whiteCard))
    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.extraLarge))
  }

  /*
   茶葉画像を表示するセクションを返します。
   */
  private var imageSection: some View {
    Group {
      if let uiImage = loadImage(from: teaLeaf.imagePath) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.extraLarge))
          .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 3)
      } else {
        RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.extraLarge)
          .fill(Color.gray.opacity(AppConstants.UI.Opacity.grayMedium))
          .overlay {
            VStack(spacing: 8) {
              Image(systemName: AppConstants.UI.UIStrings.Content.photo)
                .font(.system(size: AppConstants.UI.FontSizes.errorImageIcon))
                .foregroundStyle(.secondary)
              Text(AppConstants.UI.UIStrings.Placeholders.imageLoadError)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
          .frame(height: 200)
      }
    }
  }

  /*
   取引リクエストセクションを返します。
   */
  private var tradeRequestSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("取引リクエスト")
        .font(AppConstants.UI.Typography.FontScale.sectionTitle)

      if teaLeaf.tradeStatus == .available {
        Button {
          submitTradeRequest()
        } label: {
          HStack {
            Image(systemName: "envelope.fill")
            Text(AppConstants.UI.UIStrings.Actions.submitTradeRequest)
              .fontWeight(.semibold)
          }
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
      } else {
        HStack {
          Image(systemName: AppConstants.UI.UIStrings.Content.infoCircleFill)
          Text(teaLeaf.tradeStatus == .pending ? AppConstants.UI.Alerts.Messages.tradeRequestUnavailable : AppConstants.UI.Alerts.Messages.tradeCompleted)
            .font(AppConstants.UI.Typography.FontScale.statusBody)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
      }
    }
    .padding(AppConstants.UI.Padding.large)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(AppConstants.UI.Opacity.whiteCard))
    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.extraLarge))
  }

  /*
   ステータスに応じた色を返します。
   */
  private var statusColor: Color {
    switch teaLeaf.tradeStatus {
    case .available:
      return .green
    case .pending:
      return .orange
    case .completed:
      return .gray
    }
  }

  /*
   現在のステータスから遷移可能な次ステータスを返します。
   */
  private var nextStatus: TradeStatus? {
    switch teaLeaf.tradeStatus {
    case .available:
      return .pending
    case .pending:
      return .completed
    case .completed:
      return nil
    }
  }

  /*
   クイック操作ボタンに表示する文言を返します。
   */
  private var quickActionTitle: String {
    switch teaLeaf.tradeStatus {
    case .available:
      return "交渉中へ進める"
    case .pending:
      return "交換完了へ進める"
    case .completed:
      return "この取引は完了済みです"
    }
  }

  /*
   タグ風ラベルを返します。
   */
  private func tagLabel(_ text: String, tint: Color) -> some View {
    Text(text)
      .font(.caption.weight(.semibold))
      .foregroundStyle(tint)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(tint.opacity(0.12))
      .clipShape(Capsule())
  }

  /*
   ファイルパスから画像を読み込みます。
   */
  private func loadImage(from path: String) -> UIImage? {
    guard !path.isEmpty else { return nil }
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: path) else { return nil }
    return UIImage(contentsOfFile: path)
  }

  /*
   タイトルと値の行を返します。
   */
  private func detailRow(_ title: String, value: String) -> some View {
    HStack {
      Text(title)
        .font(AppConstants.UI.Typography.FontScale.statusTitle)
      Spacer()
      Text(value)
        .font(AppConstants.UI.Typography.FontScale.statusBody)
        .foregroundStyle(.secondary)
    }
  }

  /*
   コンテキスト保存を実行します。
   */
  private func saveContext() {
    do {
      try modelContext.save()
    } catch {
      saveErrorMessage = "変更内容を保存できませんでした。時間をおいて再度お試しください。"
      isShowingSaveError = true
    }
  }

  /*
   詳細情報の編集状態を開始します。
   */
  private func startEditingDetail() {
    editableRemainingGrams = teaLeaf.remainingGrams
    editableExpiryDate = teaLeaf.expiryDate
    editableDescription = teaLeaf.description
    isEditingDetail = true
  }

  /*
   詳細情報編集を破棄して表示モードへ戻します。
   */
  private func cancelEditingDetail() {
    isEditingDetail = false
  }

  /*
   編集内容をモデルへ反映して保存します。
   */
  private func commitDetailEdits() {
    teaLeaf.remainingGrams = editableRemainingGrams
    teaLeaf.expiryDate = editableExpiryDate
    teaLeaf.description = editableDescription
    do {
      try modelContext.save()
      isEditingDetail = false
    } catch {
      saveErrorMessage = "変更内容を保存できませんでした。時間をおいて再度お試しください。"
      isShowingSaveError = true
    }
  }

  /*
   取引リクエストを送信します。
   */
  private func submitTradeRequest() {
    guard let currentUser = users.first else {
      tradeRequestMessage = AppConstants.UI.Alerts.Messages.userDataNotFound
      isShowingTradeRequestAlert = true
      return
    }
    
    guard let owner = teaLeaf.owner else {
      tradeRequestMessage = AppConstants.UI.Alerts.Messages.ownerDataNotFound
      isShowingTradeRequestAlert = true
      return
    }
    
    // 自分自身の茶葉にはリクエストできない
    if currentUser.id == owner.id {
      tradeRequestMessage = "自分が出品した茶葉には取引リクエストを送信できません。"
      isShowingTradeRequestAlert = true
      return
    }
    
    let trade = Trade(
      teaLeaf: teaLeaf,
      requester: currentUser,
      owner: owner,
      status: .pending
    )
    
    modelContext.insert(trade)
    
    do {
      try modelContext.save()
      teaLeaf.tradeStatus = .pending
      try modelContext.save()
      tradeRequestMessage = "取引リクエストを送信しました。出品者の承認をお待ちください。"
      isShowingTradeRequestAlert = true
    } catch {
      tradeRequestMessage = "取引リクエストの送信に失敗しました。時間をおいて再度お試しください。"
      isShowingTradeRequestAlert = true
    }
  }

  /*
   Apple Mapsで茶葉の位置情報を開きます。
   */
  private func openInMaps() {
    let coordinate = CLLocationCoordinate2D(
      latitude: teaLeaf.latitude,
      longitude: teaLeaf.longitude
    )
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = teaLeaf.name
    mapItem.openInMaps()
  }
}

#Preview {
  NavigationStack {
    TeaLeafDetailView(teaLeaf: PreviewContainer.sampleTeaLeaves[0])
  }
  .modelContainer(PreviewContainer.shared)
}
