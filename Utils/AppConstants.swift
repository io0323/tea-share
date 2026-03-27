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
    }
  }
}
