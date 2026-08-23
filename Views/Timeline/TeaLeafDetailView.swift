import SwiftUI
import SwiftData
import MapKit

/*
 茶葉カードから遷移する詳細画面です。
 */
struct TeaLeafDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Bindable var teaLeaf: TeaLeaf
  @State private var isEditingDetail = AppConstants.Defaults.UI.isEditingDetail
  @State private var editableRemainingGrams = AppConstants.Defaults.State.editableRemainingGrams
  @State private var editableExpiryDate = Date()
  @State private var editableDescription = AppConstants.Defaults.State.editableDescription
  @State private var isShowingSaveError = AppConstants.Defaults.UI.isShowingSaveError
  @State private var saveErrorMessage = AppConstants.Defaults.State.saveErrorMessage
  @State private var isShowingTradeRequestAlert = AppConstants.Defaults.UI.isShowingTradeRequestAlert
  @State private var tradeRequestMessage = AppConstants.Defaults.State.tradeRequestMessage
  @Query private var users: [User]
  @AppStorage(AppConstants.Storage.currentUserIdKey)
  private var currentUserId = ""

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.card) {
        if !teaLeaf.imagePath.isEmpty {
          imageSection
        }
        headerCard
        statusSection
        quickStatusSection
        tradeRequestSection
        detailSection
      }
      .padding(AppConstants.UI.Layout.Padding.extraLarge)
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
    VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.section) {
      Text(teaLeaf.name)
        .font(AppConstants.UI.Typography.FontScale.detailTitle)
      Text(teaLeaf.brand)
        .font(AppConstants.UI.Typography.FontScale.detailSubtitle)
        .foregroundStyle(.secondary)

      HStack(spacing: AppConstants.UI.Layout.Spacing.tag) {
        tagLabel(teaLeaf.category.rawValue, tint: .green)
        tagLabel(teaLeaf.tradeStatus.rawValue, tint: statusColor)
      }
    }
    .padding(AppConstants.UI.Layout.Padding.cardHeader)
    .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity, alignment: AppConstants.UI.FrameAlignment.leading)
    .background(AppConstants.UI.BackgroundColor.whiteCard)
    .clipShape(AppConstants.UI.ClipShape.roundedRectangleExtraLarge)
    .shadow(color: AppConstants.UI.ShadowStyle.blackLight, radius: AppConstants.UI.Shadow.largeRadius, x: 0, y: AppConstants.UI.Shadow.buttonOffset)
  }

  /*
   取引状態を変更するセクションを返します。
   */
  private var statusSection: some View {
    VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.section) {
      Text(AppConstants.UI.UIStrings.Detail.Sections.tradeStatus)
        .font(AppConstants.UI.Typography.FontScale.sectionTitle)

      Picker(
        AppConstants.UI.UIStrings.Labels.tradeStatus,
        selection: $teaLeaf.tradeStatus
      ) {
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
    .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity, alignment: AppConstants.UI.FrameAlignment.leading)
    .background(AppConstants.UI.BackgroundColor.whiteCard)
    .clipShape(AppConstants.UI.ClipShape.roundedRectangleExtraLarge)
  }

  /*
   ワンタップで次ステータスへ進めるセクションを返します。
   */
  private var quickStatusSection: some View {
    VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.section) {
      Text(AppConstants.UI.UIStrings.Detail.Sections.quickActions)
        .font(AppConstants.UI.Typography.FontScale.sectionTitle)

      Button {
        guard let nextStatus else { return }
        teaLeaf.tradeStatus = nextStatus
        saveContext()
      } label: {
        HStack {
          Image(systemName: AppConstants.UI.UIStrings.Content.arrowRightCircleFill)
          Text(quickActionTitle)
            .fontWeight(AppConstants.UI.Typography.FontWeight.semibold)
        }
        .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity)
      }
      .buttonStyle(AppConstants.UI.ButtonStyle.borderedProminent)
      .disabled(nextStatus == nil)
    }
    .padding(AppConstants.UI.Padding.large)
    .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity, alignment: AppConstants.UI.FrameAlignment.leading)
    .background(AppConstants.UI.BackgroundColor.whiteCard)
    .clipShape(AppConstants.UI.ClipShape.roundedRectangleExtraLarge)
  }

  /*
   残量や期限などの詳細情報を返します。
   */
  private var detailSection: some View {
    VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.detailSection) {
      HStack {
        Text(AppConstants.UI.UIStrings.Detail.Sections.details)
          .font(AppConstants.UI.Typography.FontScale.sectionTitle)
        Spacer()
        if isEditingDetail {
          Text(
            StringFormatter.format(
              StringFormatter.format(
                AppConstants.UI.UIStrings.Labels.characterCount,
                key: "count",
                value: editableDescription.count
              ),
              key: "max",
              value: AppConstants.TextLimits.descriptionMaxLength
            )
          )
            .font(AppConstants.UI.Typography.Font.footnote)
            .foregroundStyle(
              editableDescription.count >= AppConstants.TextLimits.descriptionMaxLength
                ? .orange
                : .secondary
            )
        }
      }

      if isEditingDetail {
        Stepper(
          StringFormatter.format(AppConstants.UI.UIStrings.Detail.Fields.remainingWithGrams, key: "grams", value: editableRemainingGrams),
          value: $editableRemainingGrams,
          in: AppConstants.ValidationLimits.minRemainingGrams...AppConstants.ValidationLimits.maxRemainingGrams,
          step: 5
        )
        .disabled(AppConstants.Defaults.UI.ButtonState.disabled)
        DatePicker(
          AppConstants.UI.UIStrings.Detail.Fields.expiry,
          selection: $editableExpiryDate,
          displayedComponents: .date
        )
        TextField(
          AppConstants.UI.UIStrings.Labels.description,
          text: $editableDescription,
          axis: .vertical
        )
          .lineLimit(3...8)
      } else {
        detailRow(
          AppConstants.UI.UIStrings.Detail.Fields.remaining,
          value: "\(teaLeaf.remainingGrams)g"
        )
        detailRow(
          AppConstants.UI.UIStrings.Detail.Fields.expiry,
          value: DateFormatterHelper.formatDate(teaLeaf.expiryDate)
        )
        detailRow(
          AppConstants.UI.UIStrings.Detail.Fields.seller,
          value: teaLeaf.owner?.username
            ?? AppConstants.UI.UIStrings.Placeholders.notSet
        )
        detailRow(
          AppConstants.UI.UIStrings.Detail.Fields.area,
          value: teaLeaf.owner?.location
            ?? AppConstants.UI.UIStrings.Placeholders.notSet
        )
        detailRow(
          AppConstants.UI.UIStrings.Detail.Fields.latitude,
          value: String(format: "%.5f", teaLeaf.latitude)
        )
        detailRow(
          AppConstants.UI.UIStrings.Detail.Fields.longitude,
          value: String(format: "%.5f", teaLeaf.longitude)
        )

        Button {
          openInMaps()
        } label: {
          HStack {
            Image(systemName: AppConstants.UI.UIStrings.Content.mapFill)
            Text(AppConstants.UI.UIStrings.Actions.openInMap)
              .fontWeight(AppConstants.UI.Typography.FontWeight.semibold)
          }
          .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity)
        }
        .buttonStyle(AppConstants.UI.ButtonStyle.borderedProminent)

        VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.medium) {
          Text(AppConstants.UI.UIStrings.Labels.description)
            .font(AppConstants.UI.Typography.FontScale.sectionSubtitle)
          Text(teaLeaf.description.isEmpty ? AppConstants.UI.UIStrings.Placeholders.descriptionEmpty : teaLeaf.description)
            .font(AppConstants.UI.Typography.FontScale.detailBody)
            .foregroundStyle(.secondary)
        }
      }
    }
    .padding(AppConstants.UI.Padding.large)
    .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity, alignment: AppConstants.UI.FrameAlignment.leading)
    .background(AppConstants.UI.BackgroundColor.whiteCard)
    .clipShape(AppConstants.UI.ClipShape.roundedRectangleExtraLarge)
  }

  /*
   茶葉画像を表示するセクションを返します。
   */
  private var imageSection: some View {
    Group {
      if let uiImage = TeaImageStorage.loadImage(from: teaLeaf.imagePath) {
        Image(uiImage: uiImage)
          .resizable()
          .aspectRatio(
            contentMode: AppConstants.UI.ImageScaling.scaledToFit
          )
          .clipShape(AppConstants.UI.ClipShape.roundedRectangleExtraLarge)
          .shadow(color: AppConstants.UI.ShadowStyle.imageOpacity, radius: AppConstants.UI.Shadow.imageRadius, x: 0, y: AppConstants.UI.Shadow.imageOffset)
      } else {
        RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.extraLarge)
          .fill(AppConstants.UI.FillColor.gray)
          .overlay {
            VStack(spacing: AppConstants.UI.Layout.Spacing.vStack) {
              Image(systemName: AppConstants.UI.UIStrings.Content.photo)
                .font(.system(size: AppConstants.UI.FontSizes.errorImageIcon))
                .foregroundStyle(.secondary)
              Text(AppConstants.UI.UIStrings.Placeholders.imageLoadError)
                .font(AppConstants.UI.Typography.Font.caption)
                .foregroundStyle(.secondary)
            }
          }
          .frame(height: AppConstants.UI.Frame.imageErrorHeight)
      }
    }
  }

  /*
   取引リクエストセクションを返します。
   */
  private var tradeRequestSection: some View {
    VStack(alignment: .leading, spacing: AppConstants.UI.Layout.Spacing.section) {
      Text(AppConstants.UI.UIStrings.Detail.Sections.tradeRequest)
        .font(AppConstants.UI.Typography.FontScale.sectionTitle)

      if teaLeaf.tradeStatus == .available {
        Button {
          submitTradeRequest()
        } label: {
          HStack {
            Image(systemName: AppConstants.UI.UIStrings.Content.envelopeFill)
            Text(AppConstants.UI.UIStrings.Actions.submitTradeRequest)
              .fontWeight(AppConstants.UI.Typography.FontWeight.semibold)
          }
          .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity)
        }
        .buttonStyle(AppConstants.UI.ButtonStyle.borderedProminent)
        .tint(AppConstants.UI.TintColor.blue)
      } else {
        HStack {
          Image(systemName: AppConstants.UI.UIStrings.Content.infoCircleFill)
          Text(teaLeaf.tradeStatus == .pending ? AppConstants.UI.Alerts.Messages.tradeRequestUnavailable : AppConstants.UI.Alerts.Messages.tradeCompleted)
            .font(AppConstants.UI.Typography.FontScale.statusBody)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity, alignment: AppConstants.UI.FrameAlignment.leading)
        .padding(.vertical, AppConstants.UI.Padding.verticalMedium)
      }
    }
    .padding(AppConstants.UI.Padding.large)
    .frame(maxWidth: AppConstants.UI.FrameAlignment.maxWidthInfinity, alignment: AppConstants.UI.FrameAlignment.leading)
    .background(AppConstants.UI.BackgroundColor.whiteCard)
    .clipShape(AppConstants.UI.ClipShape.roundedRectangleExtraLarge)
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
      return AppConstants.UI.UIStrings.Detail.QuickActions.moveToPending
    case .pending:
      return AppConstants.UI.UIStrings.Detail.QuickActions.moveToCompleted
    case .completed:
      return AppConstants.UI.UIStrings.Detail.QuickActions.alreadyCompleted
    }
  }

  /*
   タグ風ラベルを返します。
   */
  private func tagLabel(_ text: String, tint: Color) -> some View {
    Text(text)
      .font(.caption.weight(AppConstants.UI.Typography.FontWeight.semibold))
      .foregroundStyle(tint)
      .padding(.horizontal, AppConstants.UI.Padding.badgeHorizontal)
      .padding(.vertical, AppConstants.UI.Padding.badgeVertical)
      .background(tint.opacity(AppConstants.UI.Opacity.badgeBackground))
      .clipShape(AppConstants.UI.ClipShape.capsule)
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
      saveErrorMessage =
        AppConstants.UI.UIStrings.Detail.SaveErrors.detailSaveFailed
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
      saveErrorMessage =
        AppConstants.UI.UIStrings.Detail.SaveErrors.detailSaveFailed
      isShowingSaveError = true
    }
  }

  /*
   取引リクエストを送信します。
   */
  private func submitTradeRequest() {
    let currentUser = CurrentUserManager.fetchCurrentUser(
      modelContext: modelContext,
      storedUserId: currentUserId
    ) ?? users.first
    guard let currentUser else {
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
      tradeRequestMessage =
        AppConstants.UI.UIStrings.Detail.TradeMessages.ownListing
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
      tradeRequestMessage = AppConstants.UI.UIStrings.Detail.TradeMessages.sent
      isShowingTradeRequestAlert = true
    } catch {
      tradeRequestMessage =
        AppConstants.UI.UIStrings.Detail.TradeMessages.sendFailed
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
