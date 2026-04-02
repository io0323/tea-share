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
    
    struct FontSizes {
      static let emptyStateIcon: Double = 30
      static let cardIcon: Double = 26
      static let mapMarkerIcon: Double = 28
      static let errorImageIcon: Double = 40
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
    }
    
    struct Layout {
      struct Padding {
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
      }
      
      struct Frame {
        static let cardHeight: CGFloat = 86
        static let errorImageHeight: CGFloat = 200
        static let progressRadius: CGFloat = 10
      }
      
      struct Spacing {
        static let tiny: CGFloat = 2
        static let small: CGFloat = 4
        static let medium: CGFloat = 6
        static let large: CGFloat = 8
        static let extraLarge: CGFloat = 10
        static let huge: CGFloat = 12
        static let card: CGFloat = 8
        static let section: CGFloat = 10
        static let button: CGFloat = 8
        static let overlay: CGFloat = 8
      }
      
      struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 10
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 14
        static let card: CGFloat = 16
      }
      
      struct Shadow {
        static let smallRadius: CGFloat = 3
        static let mediumRadius: CGFloat = 7
        static let largeRadius: CGFloat = 8
        static let cardRadius: CGFloat = 7
        static let cardOffset: CGFloat = 2
        static let buttonOffset: CGFloat = 3
      }
      
      struct Typography {
        struct Font {
          static let largeTitle: Font = .largeTitle
          static let title: Font = .title
          static let title2: Font = .title2
          static let title3: Font = .title3
          static let headline: Font = .headline
          static let subheadline: Font = .subheadline
          static let body: Font = .body
          static let callout: Font = .callout
          static let footnote: Font = .footnote
          static let caption: Font = .caption
          static let caption2: Font = .caption2
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
          static let save: String = "保存"
          static let reset: String = "リセット"
          static let saving: String = "保存中..."
          static let submitTradeRequest: String = "取引を申し込む"
          static let openInMap: String = "マップで開く"
          static let focusOnDefaultArea: String = "中心エリアへ戻る"
        }
        
        struct Labels {
          static let username: String = "ユーザー名:"
          static let id: String = "ID:"
          static let location: String = "場所:"
          static let brand: String = "ブランド"
          static let category: String = "カテゴリ"
          static let expiryDate: String = "賞味期限"
          static let remaining: String = "残量"
          static let description: String = "説明"
          static let area: String = "エリア"
          static let status: String = "ステータス"
          static let owner: String = "出品者"
          static let userDataNotFound: String = "ユーザーデータが見つかりません"
        }
        
        struct Placeholders {
          static let username: String = "ユーザー名"
          static let location: String = "場所"
          static let notSet: String = "未設定"
          static let descriptionEmpty: String = "説明は未入力です。"
          static let imageLoadError: String = "画像を読み込めません"
        }
        
        struct Content {
          static let plus: String = "出品する"
          static let leafFill: String = "leaf.fill"
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
  }
}
