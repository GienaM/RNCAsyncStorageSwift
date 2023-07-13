import Foundation
import CryptoKit

public class RNCAsyncStorageSwift {

    // MARK: - Private properties

    private let storageDirectory = "RCTAsyncLocalStorage_V1"
    private let manifestFileName = "manifest.json"
	
    private lazy var manifestDictionary: [String: Any] = {
        guard let manifestFilePath = getManifestFilePath(),
              let manifestFile = readFile(at: manifestFilePath) else {
            return [:]
        }

        return makeManifestJsonDictionary(from: manifestFile)
    }()

    // MARK: - Public methods

    public func getValueForKey<T>(_ key: String) -> T? {
        if let value = manifestDictionary[key] as? T {
            return value
        } else if let filePath = getFilePathForKey(key),
                  let value = readFile(at: filePath) as? T? {
            return value
        }

        return nil
    }

    // MARK: - Private methods

    private func getStorageDirectoryURL() -> URL? {
        let fileManager = FileManager.default

        guard let appSupportDirectoryURL = fileManager.urls(
            for: .applicationSupportDirectory, in: .userDomainMask).first,
              let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return nil
        }
        let userSupportDirectoryURL = appSupportDirectoryURL.appendingPathComponent(bundleIdentifier)

        return userSupportDirectoryURL.appendingPathComponent(storageDirectory)
    }

    private func getManifestFilePath() -> String? {
        guard let storageDirectory = getStorageDirectoryURL() else { return nil }
        let fileURL = storageDirectory.appendingPathComponent(manifestFileName)

        return fileURL.path
    }

    private func readFile(at path: String) -> String? {
        if FileManager.default.fileExists(atPath: path),
           let file = try? String(contentsOfFile: path, encoding: .utf8) {
            return file
        } else {
            return nil
        }
    }

    private func makeManifestJsonDictionary(from file: String) -> [String: Any] {
        guard let data = file.data(using: .utf8) else { return [:] }
        let json = try? JSONSerialization.jsonObject(with: data)

        return json as? [String: Any] ?? [:]
    }

    private func getFilePathForKey(_ key: String) -> String? {
        guard let storageDirectory = getStorageDirectoryURL() else { return nil }
        let safeFaileName = md5(from: key)

        return storageDirectory.appendingPathComponent(safeFaileName).path
    }

    private func md5(from string: String) -> String {
        Insecure
            .MD5
            .hash(data: Data(string.utf8))
            .map { String(format: "%02hhx", $0) }
            .joined()
    }
}
