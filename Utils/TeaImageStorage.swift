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
   指定されたファイルパスの画像を削除します。
   */
  static func deleteImage(at path: String) throws {
    guard !path.isEmpty else { return }
    
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: path) else {
      throw DeleteError.fileNotFound
    }
    
    try fileManager.removeItem(atPath: path)
  }

  /*
   指定された茶葉IDに紐づく画像を削除します。
   */
  static func deleteImage(for teaLeafId: UUID) throws {
    let fileName = "\(teaLeafId.uuidString).jpg"
    let fileURL = directoryURL.appendingPathComponent(fileName)
    
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      throw DeleteError.fileNotFound
    }
    
    try FileManager.default.removeItem(at: fileURL)
  }

  /*
   保存されているすべての画像ファイルのパスを返します。
   */
  static func getAllImagePaths() throws -> [String] {
    try ensureDirectoryExists()
    
    let fileManager = FileManager.default
    let contents = try fileManager.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: nil
    )
    
    return contents
      .filter { $0.pathExtension == "jpg" }
      .map { $0.path }
  }

  /*
   保存されているすべての画像を削除します。
   */
  static func deleteAllImages() throws {
    try ensureDirectoryExists()
    
    let fileManager = FileManager.default
    let contents = try fileManager.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: nil
    )
    
    for fileURL in contents {
      try fileManager.removeItem(at: fileURL)
    }
  }

  /*
   使用されていない画像（データベースに存在しない茶葉IDの画像）を削除します。
   */
  static func cleanupUnusedImages(activeTeaLeafIds: Set<UUID>) throws {
    try ensureDirectoryExists()
    
    let fileManager = FileManager.default
    let contents = try fileManager.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: nil
    )
    
    for fileURL in contents {
      guard fileURL.pathExtension == "jpg" else { continue }
      
      let fileName = fileURL.deletingPathExtension().lastPathComponent
      guard let teaLeafId = UUID(uuidString: fileName) else { continue }
      
      if !activeTeaLeafIds.contains(teaLeafId) {
        try fileManager.removeItem(at: fileURL)
      }
    }
  }

  /*
   画像保存時のエラー種別です。
   */
  enum SaveError: Error {
    case encodingFailed
  }

  /*
   画像削除時のエラー種別です。
   */
  enum DeleteError: Error {
    case fileNotFound
  }
}
