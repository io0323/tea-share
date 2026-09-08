import Foundation

/*
 文字列フォーマット用のユーティリティです。
 テンプレート文字列内のプレースホルダーを指定した値で置換します。
 */
enum StringFormatter {

  /*
   テンプレート文字列内のプレースホルダーを値で置換します。
   
   - Parameters:
     - template: テンプレート文字列（プレースホルダーは {key} の形式）
     - key: 置換対象のプレースホルダー名
     - value: 置換する値（String、Int、Doubleなどのdescriptionを実装した型）
   - Returns: プレースホルダーが置換された文字列
   */
  static func format(_ template: String, key: String, value: Any) -> String {
    let placeholder = "{\(key)}"
    return template.replacingOccurrences(of: placeholder, with: String(describing: value))
  }
}
