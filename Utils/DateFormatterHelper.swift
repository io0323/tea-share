import Foundation

/*
 日付フォーマットに関するユーティリティです。
 アプリ全体で一貫した日付フォーマットを提供します。
 */
enum DateFormatterHelper {

  /*
   日本語ロケールの日付フォーマッター（日付のみ）を返します。
   */
  static var japaneseDateOnly: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
  }

  /*
   日本語ロケールの日付フォーマッター（日付と時刻）を返します。
   */
  static var japaneseDateWithTime: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
  }

  /*
   日付を日本語フォーマット（日付のみ）で文字列化します。
   
   - Parameter date: フォーマットする日付
   - Returns: フォーマットされた文字列
   */
  static func formatDate(_ date: Date) -> String {
    return japaneseDateOnly.string(from: date)
  }

  /*
   日付を日本語フォーマット（日付と時刻）で文字列化します。
   
   - Parameter date: フォーマットする日付
   - Returns: フォーマットされた文字列
   */
  static func formatDateTime(_ date: Date) -> String {
    return japaneseDateWithTime.string(from: date)
  }
}
