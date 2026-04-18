import Foundation
import CoreLocation

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
      static let roundedRectangleLarge: RoundedRectangle = RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.large)
      static let roundedRectangleExtraLarge: RoundedRectangle = RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.extraLarge)
      static let roundedRectangleSheet: RoundedRectangle = RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.sheet)
      static let roundedRectangleCard: RoundedRectangle = RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.card)
      static let roundedRectangleProgress: RoundedRectangle = RoundedRectangle(cornerRadius: AppConstants.UI.CornerRadius.progress)
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
          static let userDataNotFound: String = "ユーザーデータが見つかりません。プロファイルを設定してください。"
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
          static let profile: String = "プロファイル"
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
          static let profile: String = "プロファイル"
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
        }
        
        struct Placeholders {
          static let descriptionEmpty: String = "説明はありません"
          static let imageLoadError: String = "画像の読み込みに失敗しました"
          static let unknown: String = "不明"
          static let notSet: String = "未設定"
        }
        
        struct Content {
          static let location: String = "location"
          static let tray: String = "tray"
          static let photo: String = "photo"
          static let infoCircleFill: String = "info.circle.fill"
          static let arrowRightCircleFill: String = "arrow.right.circle.fill"
          static let envelopeFill: String = "envelope.fill"
          static let mapFill: String = "map.fill"
          static let location: String = "location"
          static let xmarkCircleFill: String = "xmark.circle.fill"
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
}
