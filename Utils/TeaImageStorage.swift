import UIKit
import OSLog

/*
 茶葉画像のディスク保存・読み込みを担うユーティリティです。
 */
enum TeaImageStorage {
  private static let logger = Logger(subsystem: AppConstants.Logging.subsystem, category: AppConstants.Logging.Categories.teaImageStorage)
  
  /*
   画像保存用ディレクトリの URL をキャッシュして返します。
   */
  private static let directoryURL: URL = {
    let documents = AppConstants.ImageStorage.fileManager.urls(
      for: AppConstants.ImageStorage.FileManagerSettings.searchPathDirectory,
      in: AppConstants.ImageStorage.FileManagerSettings.searchPathDomainMask
    ).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
    return documents.appendingPathComponent(
      AppConstants.ImageStorage.subdirectory,
      isDirectory: true
    )
  }()

  /*
   保存先ディレクトリが存在することを保証します。
   */
  private static func ensureDirectoryExists() throws {
    let url = directoryURL
    if !AppConstants.ImageStorage.fileManager.fileExists(atPath: url.path) {
      logger.info("Creating image storage directory at \(url.path)")
      try AppConstants.ImageStorage.fileManager.createDirectory(
        at: url,
        withIntermediateDirectories: AppConstants.ImageStorage.createIntermediateDirectories
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
      logger.error("Failed to encode image for tea leaf \(teaLeafId)")
      throw SaveError.encodingFailed
    }
    let fileName = "\(teaLeafId.uuidString).\(AppConstants.ImageStorage.fileExtension)"
    let fileURL = directoryURL.appendingPathComponent(fileName)
    try data.write(to: fileURL, options: AppConstants.ImageStorage.writeOptions)
    logger.info("Successfully saved image for tea leaf \(teaLeafId) at \(fileURL.path)")
    return fileURL.path
  }

  /*
   ファイルパスから画像を読み込みます。
   */
  static func loadImage(from path: String) -> UIImage? {
    guard !path.isEmpty else { return nil }
    
    let fileManager = AppConstants.ImageStorage.fileManager
    guard fileManager.fileExists(atPath: path) else {
      logger.warning("Image file not found at path: \(path)")
      return nil
    }
    
    let image = UIImage(contentsOfFile: path)
    if image != nil {
      logger.debug("Successfully loaded image from path: \(path)")
    } else {
      logger.error("Failed to create UIImage from path: \(path)")
    }
    return image
  }

  /*
   指定されたファイルパスの画像を削除します。
   */
  static func deleteImage(at path: String) throws {
    guard !path.isEmpty else { return }
    
    let fileManager = AppConstants.ImageStorage.fileManager
    guard fileManager.fileExists(atPath: path) else {
      logger.warning("Attempted to delete non-existent image at path: \(path)")
      throw DeleteError.fileNotFound
    }
    
    try fileManager.removeItem(atPath: path)
    logger.info("Successfully deleted image at path: \(path)")
  }

  /*
   指定された茶葉IDに紐づく画像を削除します。
   */
  static func deleteImage(for teaLeafId: UUID) throws {
    let fileName = "\(teaLeafId.uuidString).\(AppConstants.ImageStorage.fileExtension)"
    let fileURL = directoryURL.appendingPathComponent(fileName)
    
    guard AppConstants.ImageStorage.fileManager.fileExists(atPath: fileURL.path) else {
      logger.warning("Attempted to delete non-existent image for tea leaf \(teaLeafId)")
      throw DeleteError.fileNotFound
    }
    
    try AppConstants.ImageStorage.fileManager.removeItem(at: fileURL)
    logger.info("Successfully deleted image for tea leaf \(teaLeafId)")
  }

  /*
   保存されているすべての画像ファイルのパスを返します。
   */
  static func getAllImagePaths() throws -> [String] {
    try ensureDirectoryExists()
    
    let fileManager = AppConstants.ImageStorage.fileManager
    let contents = try fileManager.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: AppConstants.ImageStorage.includingPropertiesForKeys
    )
    
    let paths = contents
      .filter { $0.pathExtension == AppConstants.ImageStorage.fileExtension }
      .map { $0.path }
    
    logger.debug("Found \(paths.count) image files in storage")
    return paths
  }

  /*
   保存されているすべての画像を削除します。
   */
  static func deleteAllImages() throws {
    try ensureDirectoryExists()
    
    let fileManager = AppConstants.ImageStorage.fileManager
    let contents = try fileManager.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: AppConstants.ImageStorage.includingPropertiesForKeys
    )
    
    logger.info("Deleting all images (\(contents.count) files)")
    for fileURL in contents {
      try fileManager.removeItem(at: fileURL)
    }
    logger.info("Successfully deleted all images")
  }

  /*
   使用されていない画像（データベースに存在しない茶葉IDの画像）を削除します。
   */
  static func cleanupUnusedImages(activeTeaLeafIds: Set<UUID>) throws {
    try ensureDirectoryExists()
    
    let fileManager = AppConstants.ImageStorage.fileManager
    let contents = try fileManager.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: AppConstants.ImageStorage.includingPropertiesForKeys
    )
    
    logger.info("Starting cleanup of unused images. Active tea leaf IDs: \(activeTeaLeafIds.count)")
    var deletedCount = 0
    
    for fileURL in contents {
      guard fileURL.pathExtension == AppConstants.ImageStorage.fileExtension else { continue }
      
      let fileName = fileURL.deletingPathExtension().lastPathComponent
      guard let teaLeafId = UUID(uuidString: fileName) else { continue }
      
      if !activeTeaLeafIds.contains(teaLeafId) {
        try fileManager.removeItem(at: fileURL)
        deletedCount += 1
        logger.debug("Deleted unused image for tea leaf \(teaLeafId)")
      }
    }
    
    logger.info("Cleanup completed. Deleted \(deletedCount) unused images")
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
