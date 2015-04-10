import Foundation

public func extract7zArchive(archivePath: String, #dirName: String, #preserveDir: Bool) -> [String] {
    return LZMAExtractor.extract7zArchive(archivePath, dirName: dirName, preserveDir: preserveDir).map { $0 as! String }
}

public func extract7zArchiveEntry(archivePath: String, #archiveEntry: String, #outPath: String) -> Bool {
    return LZMAExtractor.extractArchiveEntry(archivePath, archiveEntry: archiveEntry, outPath: outPath)
}
