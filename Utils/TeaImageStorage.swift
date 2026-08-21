import UIKit

/*
 茶葉画像のディスク保存・読み込みを担うユーティリティです。
 */
enum TeaImageStorage {

  /*
   画像保存用ディレクトリの URL を返します。
   */
  private static var directoryURL: URL {
    let documents = FileManager.default.urls(
      for: .documentDirectory,
      in: .userDomainMask
    ).first!
    return documents.appendingPathComponent(
      AppConstants.ImageStorage.subdirectory,
      isDirectory: true
    )
  }

  /*
   保存先ディレクトリが存在することを保証します。
   
   - Throws: ディレクトリの作成に失敗した場合
   */
  private static func ensureDirectoryExists() throws {
    let url = directoryURL
    if !FileManager.default.fileExists(atPath: url.path) {
      do {
        try FileManager.default.createDirectory(
          at: url,
          withIntermediateDirectories: true
        )
      } catch {
        throw SaveError.directoryCreationFailed
      }
    }
  }

  /*
   茶葉 ID に紐づく画像を JPEG 保存し、ファイルパスを返します。
   
   - Parameters:
     - image: 保存する画像
     - teaLeafId: 茶葉のID（ファイル名として使用）
   - Returns: 保存したファイルのパス
   - Throws: ディレクトリ作成失敗、エンコード失敗、ファイル書き込み失敗の場合
   */
  static func saveImage(
    _ image: UIImage,
    teaLeafId: UUID
  ) throws -> String {
    try ensureDirectoryExists()
    guard let data = image.jpegData(
      compressionQuality: AppConstants.ImageStorage.jpegCompressionQuality
    ) else {
      throw SaveError.encodingFailed
    }
    let fileName = "\(teaLeafId.uuidString).jpg"
    let fileURL = directoryURL.appendingPathComponent(fileName)
    do {
      try data.write(to: fileURL, options: .atomic)
    } catch {
      throw SaveError.fileWriteFailed
    }
    return fileURL.path
  }

  /*
   ファイルパスから画像を読み込みます。
   
   - Parameter path: 画像ファイルのパス
   - Returns: 読み込んだ画像、失敗した場合はnil
   */
  static func loadImage(from path: String) -> UIImage? {
    guard !path.isEmpty else { return nil }
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: path) else { return nil }
    return UIImage(contentsOfFile: path)
  }

  /*
   画像保存時のエラー種別です。
   */
  enum SaveError: LocalizedError {
    case encodingFailed
    case directoryCreationFailed
    case fileWriteFailed

    var errorDescription: String? {
      switch self {
      case .encodingFailed:
        return "画像のエンコードに失敗しました"
      case .directoryCreationFailed:
        return "保存ディレクトリの作成に失敗しました"
      case .fileWriteFailed:
        return "ファイルの書き込みに失敗しました"
      }
    }
  }
}
