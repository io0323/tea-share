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
   */
  private static func ensureDirectoryExists() throws {
    let url = directoryURL
    if !FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.createDirectory(
        at: url,
        withIntermediateDirectories: true
      )
    }
  }

  /*
   茶葉 ID に紐づく画像を JPEG 保存し、ファイルパスを返します。
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
    try data.write(to: fileURL, options: .atomic)
    return fileURL.path
  }

  /*
   ファイルパスから画像を読み込みます。
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
  enum SaveError: Error {
    case encodingFailed
  }
}
