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
}
