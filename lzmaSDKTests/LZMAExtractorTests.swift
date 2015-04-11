import Foundation
import XCTest
import lzmaSDK

class SwiftWrapperTest : XCTestCase {
    let test7z = NSBundle(forClass: SwiftWrapperTest.self).pathForResource("test.7z", ofType:nil)!

    func testExtract7zArchive() {
        let result = extract7zArchive(test7z, dirName: tmpFile("Test"), preserveDir: false)

        XCTAssertEqual(1, count(result))
        XCTAssertEqual("make.out", result[0].lastPathComponent)
    }

    func testExtract7zArchiveEntry() {
        let entry = "make.out"
        let outPath = tmpFile("make.out")
        XCTAssert(extract7zArchiveEntry(test7z, archiveEntry: entry, outPath: outPath))

        let data = NSData(contentsOfFile: outPath)!
        XCTAssertEqual(596, data.length)
    }

    func tmpFile(name: String) -> String {
        let tmpFile = NSTemporaryDirectory().stringByAppendingPathComponent(name)
        NSFileManager.defaultManager().removeItemAtPath(tmpFile, error: nil)
        return tmpFile
    }
}
