import Foundation
import CoreLocation
import SwiftUI

/*
 アプリケーション全体で使用する定数を定義します。
 */
struct AppConstants {
  
  /*
   デフォルトの中心座標（東京）を定義します。
   */
  struct Location {
    static let defaultLatitude: Double = 35.681236
    static let defaultLongitude: Double = 139.767125
    static let randomLatitudeRange: ClosedRange<Double> = -0.04...0.04
    static let randomLongitudeRange: ClosedRange<Double> = -0.04...0.04
  }
  
  /*
   マップのデフォルト表示範囲を定義します。
   */
  struct Map {
    static let defaultLatitudeDelta: Double = 0.15
    static let defaultLongitudeDelta: Double = 0.15
  }
  
  /*
   テキスト入力の制限値を定義します。
   */
  struct TextLimits {
    static let descriptionMaxLength: Int = 300
  }
  
  /*
   入力検証の制限値を定義します。
   */
  struct ValidationLimits {
    static let minRemainingGrams: Int = 1
    static let maxRemainingGrams: Int = 1000
    static let minUsernameLength: Int = 1
    static let maxUsernameLength: Int = 50
    static let minLocationLength: Int = 1
    static let maxLocationLength: Int = 100
    static let minTeaNameLength: Int = 1
    static let maxTeaNameLength: Int = 100
  }
  
  /*
   UIデザインの定数を定義します。
   */
  struct UI {
    struct Colors {
      static let greenOpacity: Double = 0.10
      static let greenForegroundOpacity: Double = 0.65
      static let greenBadgeOpacity: Double = 0.12
      static let greenSelectedOpacity: Double = 0.80
      static let greenTextOpacity: Double = 0.90
      static let whiteOpacity: Double = 0.9
      static let whiteBackgroundOpacity: Double = 0.86
      static let whiteCardOpacity: Double = 0.92
      static let whiteChipOpacity: Double = 0.85
      static let blackShadowOpacity: Double = 0.12
      static let blackCardShadowOpacity: Double = 0.07
    }
    
    struct ClipShape {
      static let capsule: Capsule = Capsule()
      static let roundedRectangleLarge: RoundedRectangle = RoundedRectangle(
        cornerRadius: Layout.CornerRadius.large
      )
      static let roundedRectangleExtraLarge: RoundedRectangle = RoundedRectangle(
        cornerRadius: Layout.CornerRadius.extraLarge
      )
      static let roundedRectangleSheet: RoundedRectangle = RoundedRectangle(
        cornerRadius: Layout.CornerRadius.sheet
      )
      static let roundedRectangleCard: RoundedRectangle = RoundedRectangle(
        cornerRadius: Layout.CornerRadius.card
      )
      static let roundedRectangleProgress: RoundedRectangle = RoundedRectangle(
        cornerRadius: Layout.CornerRadius.progress
      )
    }
    
    struct Opacity {
      static let greenButton: Double = 0.85
      static let backgroundWhite: Double = 0.9
      static let cardBackground: Double = 0.86
      static let cardWhite: Double = 0.92
      static let chipBackground: Double = 0.85
      static let shadow: Double = 0.12
      static let cardShadow: Double = 0.07
      static let whiteHigh: Double = 0.9
      static let whiteCard: Double = 0.92
      static let grayLight: Double = 0.1
      static let grayMedium: Double = 0.2
      static let blackOverlay: Double = 0.15
      static let blackLight: Double = 0.08
      static let backgroundGradient: Double = 0.25
      static let badgeBackground: Double = 0.12
      static let filterSelected: Double = 0.9
      static let filterUnselected: Double = 0.9
      static let categorySelected: Double = 0.85
      static let secondaryCapsule: Double = 0.3
    }
    
    struct BasicColor {
      static let white: Color = .white
      static let black: Color = .black
      static let green: Color = .green
      static let blue: Color = .blue
      static let gray: Color = .gray
      static let secondary: Color = .secondary
    }
    
    struct Layout {
      struct Padding {
        static let default: CGFloat = 16
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 14
        static let extraLarge: CGFloat = 16
        static let huge: CGFloat = 20
        static let cardHorizontal: CGFloat = 12
        static let cardVertical: CGFloat = 10
        static let buttonHorizontal: CGFloat = 12
        static let buttonVertical: CGFloat = 8
        static let filterHorizontal: CGFloat = 10
        static let filterVertical: CGFloat = 6
        static let cardHeader: CGFloat = 14
        static let chipHorizontal: CGFloat = 10
        static let chipVertical: CGFloat = 6
        static let badgeHorizontal: CGFloat = 8
        static let badgeVertical: CGFloat = 4
        static let top: CGFloat = 8
        static let bottom: CGFloat = 20
        static let verticalSmall: CGFloat = 2
        static let verticalMedium: CGFloat = 8
        static let filterButtonVertical: CGFloat = 7
      }
      
      struct Frame {
        static let cardHeight: CGFloat = 44
        static let errorImageHeight: CGFloat = 4
        static let imageMaxHeight: CGFloat = 180
        static let imageErrorHeight: CGFloat = 200
        static let progressRadius: CGFloat = 10
      }
      
      struct FrameAlignment {
        static let maxWidthInfinity: CGFloat = .infinity
        static let leading: Alignment = .leading
        static let center: Alignment = .center
      }
      
      struct Spacing {
        static let tiny: CGFloat = 2
        static let small: CGFloat = 4
        static let medium: CGFloat = 6
        static let large: CGFloat = 8
        static let extraLarge: CGFloat = 10
        static let huge: CGFloat = 12
        static let section: CGFloat = 10
        static let form: CGFloat = 12
        static let button: CGFloat = 8
        static let grid: CGFloat = 12
        static let card: CGFloat = 16
        static let tag: CGFloat = 8
        static let chip: CGFloat = 6
        static let overlay: CGFloat = 8
        static let hStack: CGFloat = 6
        static let vStack: CGFloat = 8
        static let detailSection: CGFloat = 12
        static let emptyState: CGFloat = 10
      }
      
      struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 16
        static let card: CGFloat = 10
        static let button: CGFloat = 10
        static let sheet: CGFloat = 12
        static let progress: CGFloat = 10
      }
      
      struct Shadow {
        static let smallRadius: CGFloat = 3
        static let mediumRadius: CGFloat = 7
        static let largeRadius: CGFloat = 8
        static let cardRadius: CGFloat = 7
        static let cardOffset: CGFloat = 2
        static let buttonOffset: CGFloat = 3
        static let imageRadius: CGFloat = 8
        static let imageOffset: CGFloat = 3
        static let imageOpacity: Double = 0.1
      }
    }
    
    /*
     Layout 内グループへの短縮参照です。
     */
    typealias Padding = Layout.Padding
    typealias Frame = Layout.Frame
    typealias CornerRadius = Layout.CornerRadius
    typealias Shadow = Layout.Shadow
    
    /*
     よく使うボタンスタイルのプリセットです。
     */
    struct ButtonStyle {
      static let plain: PlainButtonStyle = PlainButtonStyle()
      static let bordered: BorderedButtonStyle = BorderedButtonStyle()
      static let borderedProminent: BorderedProminentButtonStyle =
        BorderedProminentButtonStyle()
    }
    
    /*
     SF Symbols などアイコン用の基準サイズです。
     */
    struct FontSizes {
      static let emptyStateIcon: CGFloat = 36
      static let cardIcon: CGFloat = 28
      static let errorImageIcon: CGFloat = 48
      static let mapMarkerIcon: CGFloat = 14
    }
    
    struct Typography {
      struct Font {
        static let largeTitle: Font = .largeTitle
        static let title: Font = .title
        static let title2: Font = .title2
        static let title3: Font = .title3
        static let headline: Font = .headline
        static let subheadline: Font = .subheadline
        static let footnote: Font = .footnote
        static let caption: Font = .caption
        static let caption2: Font = .caption2
        static let body: Font = .body
        static let system: Font = .system
        static let systemBold: Font = .systemBold
        static let systemItalic: Font = .systemItalic
        static let systemBoldItalic: Font = .systemBoldItalic
        static let systemMedium: Font = .systemMedium
        static let systemSemibold: Font = .systemSemibold
        static let systemLight: Font = .systemLight
        static let systemThin: Font = .systemThin
      }
      
      struct FontWeight {
        static let bold: Font.Weight = .bold
        static let heavy: Font.Weight = .heavy
        static let medium: Font.Weight = .medium
        static let regular: Font.Weight = .regular
        static let semibold: Font.Weight = .semibold
        static let thin: Font.Weight = .thin
        static let light: Font.Weight = .light
      }
      
      struct FontScale {
        static let cardTitle: Font = .headline
        static let cardSubtitle: Font = .caption.weight(.semibold)
        static let cardBody: Font = .caption
        static let sectionTitle: Font = .headline
        static let sectionSubtitle: Font = .subheadline.weight(.semibold)
        static let sectionBody: Font = .body
        static let buttonTitle: Font = .headline
        static let chipTitle: Font = .subheadline.weight(.medium)
        static let detailTitle: Font = .title3.weight(.semibold)
        static let detailSubtitle: Font = .subheadline
        static let detailBody: Font = .body
        static let statusTitle: Font = .subheadline.weight(.semibold)
        static let statusBody: Font = .subheadline
      }
    }
    
    struct ImageScaling {
      static let scaledToFill: ContentMode = .scaledToFill
      static let scaledToFit: ContentMode = .scaledToFit
    }
    
    struct BackgroundColor {
      static let whiteCard: Color = Color.white.opacity(AppConstants.UI.Opacity.whiteCard)
      static let backgroundWhite: Color = Color.white.opacity(AppConstants.UI.Opacity.backgroundWhite)
      static let whiteHigh: Color = Color.white.opacity(AppConstants.UI.Opacity.whiteHigh)
      static let cardBackground: Color = Color.white.opacity(AppConstants.UI.Opacity.cardBackground)
      static let cardWhite: Color = Color.white.opacity(AppConstants.UI.Opacity.cardWhite)
    }
    
    struct ShadowStyle {
      static let blackLight: Color = .black.opacity(AppConstants.UI.Opacity.blackLight)
      static let shadow: Color = .black.opacity(AppConstants.UI.Opacity.shadow)
      static let cardShadow: Color = .black.opacity(AppConstants.UI.Opacity.cardShadow)
      static let imageOpacity: Color = .black.opacity(
        Layout.Shadow.imageOpacity
      )
    }
    
    struct TintColor {
      static let blue: Color = .blue
    }
    
    struct FillColor {
      static let green: Color = Color.green.opacity(AppConstants.UI.Colors.greenOpacity)
      static let gray: Color = Color.gray.opacity(AppConstants.UI.Opacity.grayMedium)
      static let secondary: Color = Color.secondary.opacity(AppConstants.UI.Opacity.secondaryCapsule)
    }
    
    struct Alerts {
      struct Titles {
        static let saveError: String = "保存に失敗しました"
        static let saveFailed: String = "保存できませんでした"
        static let tradeRequest: String = "取引リクエスト"
        static let resetInput: String = "入力内容をリセットしますか？"
      }
      
      struct Buttons {
        static let ok: String = "OK"
        static let cancel: String = "キャンセル"
        static let reset: String = "リセット"
      }
      
      struct Messages {
        static let tradeRequestUnavailable: String = "交渉中のため新規リクエストはできません"
        static let tradeCompleted: String = "この取引は完了済みです"
        static let userDataNotFound: String =
          "ユーザーデータが見つかりません。プロフィールを設定してください。"
        static let ownerDataNotFound: String = "出品者情報が見つかりません。"
        static let resetConfirmation: String = "現在の入力内容と下書きが削除されます。"
      }
    }
    
    struct Sheets {
      struct Detents {
        static let mapDetailFraction: Double = 0.35
        static let mapDetailMedium: PresentationDetent = .medium
      }
    }
    
    struct Navigation {
      struct Titles {
        static let main: String = "TeaShare"
        static let profile: String = "プロフィール"
        static let map: String = "交換スポット"
        static let addTea: String = "新規出品"
        static let teaDetail: String = "茶葉の詳細"
      }
      
      struct Toolbar {
        struct Buttons {
          static let edit: String = "編集"
          static let done: String = "完了"
          static let cancel: String = "キャンセル"
          static let save: String = "保存"
        }
      }
      
      /*
       ルートタブのラベルと SF Symbols 名です。
       */
      struct Tab {
        struct Labels {
          static let timeline: String = "タイムライン"
          static let map: String = "マップ"
          static let profile: String = "プロフィール"
        }
        
        struct Symbols {
          static let timeline: String = "square.grid.2x2.fill"
          static let map: String = "map.fill"
          static let profile: String = "person.fill"
        }
      }
    }
    
    struct UIStrings {
      struct Actions {
        static let saving: String = "保存中..."
        static let reset: String = "リセット"
        static let openInMap: String = "地図で開く"
        static let submitTradeRequest: String = "取引リクエストを送信"
        static let focusOnDefaultArea: String = "デフォルトエリアにフォーカス"
        static let plus: String = "茶葉を追加"
      }
      
      struct Labels {
        static let username: String = "ユーザー名"
        static let id: String = "ID"
        static let location: String = "場所"
        static let description: String = "説明"
        static let userDataNotFound: String = "ユーザーデータが見つかりません"
        static let profile: String = "プロフィール"
        static let clearFilter: String = "フィルタ解除"
        static let displayCount: String = "表示中: {count}件"
        static let seller: String = "出品者: {username}"
        static let area: String = "エリア: {location}"
        static let remaining: String = "残量: {grams}g"
        static let status: String = "ステータス: {status}"
        static let updateTradeStatus: String = "取引ステータスを更新"
        static let sortBy: String = "並び替え"
        static let displayScope: String = "表示範囲"
        static let expiringOnly: String = "期限切れ/期限間近のみ"
        static let targetCount: String = "対象: {count}件"
        static let resultCount: String = "結果: {count}件"
        static let expiringCount: String = "期限注意: {count}件"
        static let noMatchingTea: String = "条件に一致する茶葉がありません"
        static let changeSearchConditions: String = "検索条件やカテゴリを変更してください"
        static let clearAllConditions: String = "条件をすべて解除"
        static let noFilterConditions: String = "フィルタ条件は未設定です"
        static let tradeStatus: String = "取引ステータス"
        static let allCategories: String = "すべて"
        static let countSuffix: String = "{count}件"
        static let characterCount: String = "{count}/{max}"
      }
      
      /*
       新規出品画面の文言です。
       */
      struct AddTea {
        struct Sections {
          static let image: String = "画像"
          static let teaInfo: String = "茶葉情報"
          static let seller: String = "出品者情報"
          static let draft: String = "下書き"
          static let validation: String = "入力チェック"
        }
        
        struct FormFields {
          static let teaName: String = "茶葉名"
          static let brand: String = "ブランド名"
          static let category: String = "カテゴリー"
          static let remaining: String = "残量: {grams}g"
          static let expiry: String = "賞味期限"
          static let description: String = "説明文"
          static let username: String = "ユーザー名"
          static let area: String = "エリア"
        }
        
        struct Actions {
          static let pickFromLibrary: String = "ライブラリから選択"
          static let takePhoto: String = "カメラで撮影"
          static let reanalyze: String = "再抽出"
          static let removeImage: String = "画像を削除"
          static let resetForm: String = "入力内容をリセット"
          static let quickRemaining: String = "クイック"
          static let expiryPreset: String = "期限プリセット"
          static let quickGrams: String = "{grams}g"
        }
        
        struct Hints {
          static let analyzingImage: String = "画像から情報を抽出中..."
          static let autoDraft: String = "入力内容は自動で下書き保存されます。"
        }
        
        struct Validation {
          static let teaNameRequired: String = "茶葉名は必須です。"
          static let teaNameMinLength: String =
            "茶葉名は{min}文字以上で入力してください。"
          static let teaNameMaxLength: String =
            "茶葉名は{max}文字以下で入力してください。"
          static let areaRequired: String = "エリアは必須です。"
          static let areaMinLength: String =
            "エリアは{min}文字以上で入力してください。"
          static let areaMaxLength: String =
            "エリアは{max}文字以下で入力してください。"
          static let remainingMin: String =
            "残量は{min}g以上で入力してください。"
          static let remainingMax: String =
            "残量は{max}g以下で入力してください。"
          static let expiryNotPast: String =
            "賞味期限は本日以降を選択してください。"
          static let usernameRequired: String = "ユーザー名は必須です。"
          static let usernameMinLength: String =
            "ユーザー名は{min}文字以上で入力してください。"
          static let usernameMaxLength: String =
            "ユーザー名は{max}文字以下で入力してください。"
        }
        
        struct Errors {
          static let imageLoadFailed: String =
            "画像の読み込みに失敗しました。別の画像を選択してください。"
          static let saveFailed: String =
            "保存処理に失敗しました。時間をおいて再度お試しください。"
        }
        
        struct Suggestions {
          static let unknownBrand: String = "ブランド不明"
          static let mockTeaName: String = "抽出候補: お茶"
          static let mockBrand: String = "抽出候補: TeaBrand"
        }
      }
      
      /*
       茶葉詳細画面の文言です。
       */
      struct Detail {
        struct Sections {
          static let tradeStatus: String = "取引ステータス"
          static let quickActions: String = "クイック操作"
          static let details: String = "詳細情報"
          static let tradeRequest: String = "取引リクエスト"
        }
        
        struct Fields {
          static let remaining: String = "残量"
          static let expiry: String = "賞味期限"
          static let seller: String = "出品者"
          static let area: String = "エリア"
          static let latitude: String = "緯度"
          static let longitude: String = "経度"
          static let remainingWithGrams: String = "残量: {grams}g"
        }
        
        struct QuickActions {
          static let moveToPending: String = "交渉中へ進める"
          static let moveToCompleted: String = "交換完了へ進める"
          static let alreadyCompleted: String = "この取引は完了済みです"
        }
        
        struct TradeMessages {
          static let ownListing: String =
            "自分が出品した茶葉には取引リクエストを送信できません。"
          static let sent: String =
            "取引リクエストを送信しました。出品者の承認をお待ちください。"
          static let sendFailed: String =
            "取引リクエストの送信に失敗しました。時間をおいて再度お試しください。"
        }
        
        struct SaveErrors {
          static let detailSaveFailed: String =
            "変更内容を保存できませんでした。時間をおいて再度お試しください。"
          static let statusUpdateFailed: String =
            "ステータス更新を保存できませんでした。時間をおいて再度お試しください。"
        }
      }
      
      /*
       タイムライン画面の文言です。
       */
      struct Timeline {
        struct Search {
          static let placeholder: String = "茶葉名・ブランド・エリアで検索"
        }
        
        struct FilterLabels {
          static let search: String = "検索: {keyword}"
          static let category: String = "カテゴリ: {category}"
          static let scope: String = "範囲: {scope}"
          static let expiringOnly: String = "期限注意のみ"
          static let sort: String = "並び: {sort}"
        }
        
        struct Expiry {
          static let expired: String = "期限切れ"
          static let daysRemaining: String = "残り{days}日"
          static let fresh: String = "余裕あり"
        }
        
        struct Sort {
          static let expirySoon: String = "期限順"
          static let remainingHigh: String = "残量順"
          static let name: String = "名前順"
        }
        
        struct StatusScope {
          static let active: String = "募集中+交渉中"
          static let availableOnly: String = "募集中のみ"
        }
      }
      
      /*
       マップ画面のフィルタラベルです。
       */
      struct Map {
        struct Filters {
          static let allActive: String = "募集中+交渉中"
          static let availableOnly: String = "募集中のみ"
          static let pendingOnly: String = "交渉中のみ"
        }
      }
      
      /*
       プロフィール画面の文言です。
       */
      struct Profile {
        struct SaveErrors {
          static let userNotFound: String = "ユーザーデータが見つかりません。"
          static let saveFailed: String =
            "プロフィールの変更を保存できませんでした。時間をおいて再度お試しください。"
        }
      }
      
      struct Placeholders {
        static let descriptionEmpty: String = "説明はありません"
        static let imageLoadError: String = "画像の読み込みに失敗しました"
        static let unknown: String = "不明"
        static let notSet: String = "未設定"
      }
      
      struct Content {
        static let location: String = "location"
        static let leafFill: String = "leaf.fill"
        static let tray: String = "tray"
        static let photo: String = "photo"
        static let infoCircleFill: String = "info.circle.fill"
        static let arrowRightCircleFill: String = "arrow.right.circle.fill"
        static let envelopeFill: String = "envelope.fill"
        static let mapFill: String = "map.fill"
        static let xmarkCircleFill: String = "xmark.circle.fill"
        static let magnifyingglass: String = "magnifyingglass"
        static let plusIcon: String = "plus"
        static let camera: String = "camera"
        static let sparkles: String = "sparkles"
        static let trash: String = "trash"
        static let leafCircleFill: String = "leaf.circle.fill"
        static let arrowCounterclockwise: String = "arrow.counterclockwise"
        static let bubbleLeftAndBubbleRightFill: String =
          "bubble.left.and.bubble.right.fill"
        static let checkmarkSealFill: String = "checkmark.seal.fill"
        static let exclamationmarkTriangleFill: String =
          "exclamationmark.triangle.fill"
        static let clockFill: String = "clock.fill"
      }
    }
  }
  struct Defaults {
      struct State {
        static let searchText: String = ""
        static let errorMessage: String = ""
        static let saveErrorMessage: String = ""
        static let tradeRequestMessage: String = ""
        static let editableDescription: String = ""
        static let editedUsername: String = ""
        static let editedLocation: String = ""
        static let name: String = ""
        static let brand: String = ""
        static let descriptionText: String = ""
        static let location: String = "未設定"
        static let username: String = "new_user"
        static let editableRemainingGrams: Int = 0
        static let remainingGrams: Int = 50
      }
      
      struct UI {
        static let showExpiringOnly: Bool = false
        static let isPresentingAddTea: Bool = false
        static let isEditingDetail: Bool = false
        static let isShowingSaveError: Bool = false
        static let isShowingTradeRequestAlert: Bool = false
        static let isShowingCamera: Bool = false
        static let isAnalyzingImage: Bool = false
        static let isSaving: Bool = false
        static let isShowingErrorAlert: Bool = false
        static let isShowingResetAlert: Bool = false
        static let hasLoadedDraft: Bool = false
        static let isEditing: Bool = false
      }
      
      struct ButtonState {
        static let disabled: Bool = true
        static let enabled: Bool = false
      }
      
      struct Selection {
        static let sortOption: TeaTimelineSortOption = .expirySoon
        static let statusScope: TeaTimelineStatusScope = .active
        static let category: TeaCategory = .greenTea
        static let selectedCategory: TeaCategory? = nil
      }
    }
}
