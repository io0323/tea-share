import Foundation

/*
 入力値のバリデーションを行うユーティリティです。
 */
enum ValidationHelper {

  /*
   文字列の長さが指定範囲内か検証します。
   
   - Parameters:
     - value: 検証する文字列
     - minLength: 最小長（nilの場合はチェックしない）
     - maxLength: 最大長（nilの場合はチェックしない）
   - Returns: バリデーション結果（isValid: 有効かどうか, message: エラーメッセージ）
   */
  static func validateLength(
    _ value: String,
    minLength: Int? = nil,
    maxLength: Int? = nil
  ) -> (isValid: Bool, message: String?) {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if trimmed.isEmpty {
      return (false, "入力必須です")
    }
    
    if let min = minLength, trimmed.count < min {
      return (false, "\(min)文字以上で入力してください")
    }
    
    if let max = maxLength, trimmed.count > max {
      return (false, "\(max)文字以下で入力してください")
    }
    
    return (true, nil)
  }

  /*
   数値が指定範囲内か検証します。
   
   - Parameters:
     - value: 検証する数値
     - minValue: 最小値（nilの場合はチェックしない）
     - maxValue: 最大値（nilの場合はチェックしない）
   - Returns: バリデーション結果（isValid: 有効かどうか, message: エラーメッセージ）
   */
  static func validateRange(
    _ value: Int,
    minValue: Int? = nil,
    maxValue: Int? = nil
  ) -> (isValid: Bool, message: String?) {
    if let min = minValue, value < min {
      return (false, "\(min)以上の値を入力してください")
    }
    
    if let max = maxValue, value > max {
      return (false, "\(max)以下の値を入力してください")
    }
    
    return (true, nil)
  }

  /*
   日付が過去でないか検証します。
   
   - Parameter date: 検証する日付
   - Returns: バリデーション結果（isValid: 有効かどうか, message: エラーメッセージ）
   */
  static func validateNotPast(_ date: Date) -> (isValid: Bool, message: String?) {
    let today = Calendar.current.startOfDay(for: Date())
    if date < today {
      return (false, "過去の日付は指定できません")
    }
    return (true, nil)
  }

  /*
   複数のバリデーション結果を結合します。
   
   - Parameter results: バリデーション結果の配列
   - Returns: 全て有効かどうかとエラーメッセージの配列
   */
  static func combineResults(_ results: [(isValid: Bool, message: String?)]) -> (isValid: Bool, messages: [String]) {
    let messages = results.compactMap { $0.message }
    let isValid = results.allSatisfy { $0.isValid }
    return (isValid, messages)
  }
}
