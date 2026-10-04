import Foundation

/*
 文字列フォーマットを行うユーティリティです。
 */
enum StringFormatter {
  /*
   テンプレート文字列のプレースホルダーを置換します。
   
   - Parameters:
     - template: テンプレート文字列（{key}形式のプレースホルダーを含む）
     - key: 置換するキー
     - value: 置換する値
   - Returns: 置換後の文字列
   */
  static func format(_ template: String, key: String, value: Any) -> String {
    let placeholder = "{\(key)}"
    return template.replacingOccurrences(of: placeholder, with: "\(value)")
  }
}
