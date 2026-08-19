import Foundation

/*
 文字列フォーマットに関するユーティリティです。
 テンプレート文字列の置換を簡素化します。
 */
enum StringFormatter {

  /*
   テンプレート文字列のプレースホルダーを置換します。
   
   - Parameters:
     - template: テンプレート文字列（例: "こんにちは、{name}さん"）
     - replacements: 置換するキーと値のペア（例: ["name": "田中"]）
   - Returns: 置換後の文字列
   */
  static func format(
    _ template: String,
    replacements: [String: String]
  ) -> String {
    var result = template
    for (key, value) in replacements {
      result = result.replacingOccurrences(of: "{\(key)}", with: value)
    }
    return result
  }

  /*
   単一のプレースホルダーを置換します。
   
   - Parameters:
     - template: テンプレート文字列
     - key: 置換するキー
     - value: 置換する値
   - Returns: 置換後の文字列
   */
  static func format(
    _ template: String,
    key: String,
    value: String
  ) -> String {
    return template.replacingOccurrences(of: "{\(key)}", with: value)
  }

  /*
   数値を文字列に変換して置換します。
   
   - Parameters:
     - template: テンプレート文字列
     - key: 置換するキー
     - value: 置換する数値
   - Returns: 置換後の文字列
   */
  static func format(
    _ template: String,
    key: String,
    value: Int
  ) -> String {
    return template.replacingOccurrences(of: "{\(key)}", with: "\(value)")
  }
}
