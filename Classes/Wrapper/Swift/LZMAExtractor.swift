import Foundation

/// Extract all the contents of a .7z archive directly into the indicated dir.
///
/// :param: archivePath path to the .7z archive.
/// :param: dirname     dir to extract to (will be created)
/// :param: preserveDir Directory structure is ignored if preserveDir is false.
///
/// :returns: a list of extracted files
public func extract7zArchive(archivePath: String, #dirName: String, #preserveDir: Bool) -> [String] {
    return LZMAExtractor.extract7zArchive(archivePath, dirName: dirName, preserveDir: preserveDir).map { $0 as! String }
}

/// Extract just one entry from an archive and save it at the
/// path indicated by outPath.
///
/// :param: archivePath path to the .7z archive.
/// :param: archiveEntry   the entry to extract
/// :param: outPath        directory to extract to
///
/// :returns: true if successful
public func extract7zArchiveEntry(archivePath: String, #archiveEntry: String, #outPath: String) -> Bool {
    return LZMAExtractor.extractArchiveEntry(archivePath, archiveEntry: archiveEntry, outPath: outPath)
}
