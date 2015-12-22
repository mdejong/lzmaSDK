#import <XCTest/XCTest.h>

#import <lzmaSDK/lzmaSDK.h>

@interface LZMAExtractorTests : XCTestCase
@end

@implementation LZMAExtractorTests

// Return TRUE if file exists, FALSE otherwise
BOOL fileExists(NSString *filePath) {
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    return TRUE;
  } else {
    return FALSE;
  }
}

// Query open file size, then rewind to start
static uint32_t filesize(char *filepath) {
  int retcode;
  FILE *fp = fopen(filepath, "r");
  retcode = fseek(fp, 0, SEEK_END);
  assert(retcode == 0);
  uint32_t size = (uint32_t) ftell(fp);
  fclose(fp);
  return size;
}

- (void) testSmallInMem
{
  NSLog(@"START testSmallInMem");
  
  BOOL worked;
  
  // Extract files from archive into named dir in the temp dir
  
  NSString *tmpDirname = @"Extract7z";
  NSString *archiveFilename = @"test.7z";
  NSString *archiveResPath = [[NSBundle bundleForClass:LZMAExtractorTests.class] pathForResource:archiveFilename ofType:nil];
  XCTAssert(archiveResPath, @"can't find test.7z");
  
  NSArray *contents = [LZMAExtractor extract7zArchive:archiveResPath
                                           tmpDirName:tmpDirname];
  
  for (NSString *entryPath in contents) {
    NSData *outputData = [NSData dataWithContentsOfFile:entryPath];
    NSString *outStr = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    
    NSLog(@"%@", entryPath);
    NSLog(@"%@", outStr);
  }
  
  // Extract single entry "make.out" and save it as "tmp/make.out.txt" in the tmp dir.
  
  NSString *entryFilename = @"make.out";
  NSString *makeTmpFilename = @"make.out.txt";
  NSString *makeTmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:makeTmpFilename];
  
  worked = [LZMAExtractor extractArchiveEntry:archiveResPath
                                 archiveEntry:entryFilename
                                      outPath:makeTmpPath];
  
  
  XCTAssert(worked);
  if (worked) {
    NSData *outputData = [NSData dataWithContentsOfFile:makeTmpPath];
    NSString *outStr = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", makeTmpFilename);
    NSLog(@"%@", outStr);
  }
  
  NSLog(@"DONE testSmallInMem");
}

// This test decodes a small text file from the attached resource test.7z
// This is a basic sanity check of the logic to decode an entry to a .7z archive.
// Because the input archive and output files are small, this test case will
// not use up much memory or emit large files. Note that because this dictionary
// size is smaller than the 1 meg k7zUnpackMapDictionaryInMemoryMaxNumBytes limit,
// this unpack operaiton will be done entirely in memory as opposed to using
// mapped memory that is paged to disk.

- (void) testFilesAndDirs
{
  NSLog(@"START testFilesAndDirs");
  
  BOOL worked;
  
  // Extract dirs files
  
  NSString *archiveFilename = @"files_dirs.7z";
  NSString *archiveResPath = [[NSBundle bundleForClass:LZMAExtractorTests.class] pathForResource:archiveFilename ofType:nil];
  NSAssert(archiveResPath, @"can't find %@", archiveFilename);
  
  NSArray *contents = [LZMAExtractor extract7zArchive:archiveResPath
                                              dirName:NSTemporaryDirectory()
                                          preserveDir:TRUE];
  
  if ((0)) {
  for (NSString *entryPath in contents) {
    NSData *outputData = [NSData dataWithContentsOfFile:entryPath];
    NSString *outStr = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", entryPath);
    NSLog(@"%@", outStr);
  }
  }
  
  XCTAssert(contents.count == 4);
  
  NSString *content;
  
  // .../d1/f1
  content = contents[0];
  XCTAssert([content hasSuffix:@"d1/f1"]);
  
  // .../d1/f2
  content = contents[1];
  XCTAssert([content hasSuffix:@"d1/f2"]);
  
  // .../d2/f_2_1
  content = contents[2];
  XCTAssert([content hasSuffix:@"d2/f_2_1"]);

  // .../d2/f_2_2
  content = contents[3];
  XCTAssert([content hasSuffix:@"d2/f_2_2"]);
  
  // Extract single entry "d2/f_2_1" and save it as "d2_f_2_1" in the tmp dir.
  
  NSString *entryFilename = @"d2/f_2_1";
  NSString *makeTmpFilename = @"d2_f_2_1";
  NSString *makeTmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:makeTmpFilename];
  
  worked = [LZMAExtractor extractArchiveEntry:archiveResPath
                                 archiveEntry:entryFilename
                                      outPath:makeTmpPath];
  
  XCTAssert(worked);
  
  if (worked) {
    NSData *outputData = [NSData dataWithContentsOfFile:makeTmpPath];
    NSString *outStr = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    XCTAssert([outStr hasSuffix:@"12\n"]);
  }
  
  NSLog(@"DONE testFilesAndDirs");
}

// This test will extract a 500 meg file from a solid archive, this 500 meg file is way too large
// to fit into regular memory, but it is smaller than the 700 meg limit on mapped memory
// in iOS. This test will pass as long as the modification to the lzma SDK is implemented
// so that memory is paged to disk when the dictionary size is large.
//
// Create:
//
// 7za a -mx=9 halfgig.7z halfgig.data
//
// The output of:
//
// 7za l -slt halfgig.7z
//
// Shows that the entire 500 meg file is stored as one large block.

- (void) testHalfGig
{
  NSLog(@"START testHalfGig");
  
  // Extract files from archive into named dir in the temp dir
  
  NSString *archiveFilename = @"halfgig.7z";
  NSString *archiveResPath = [[NSBundle bundleForClass:LZMAExtractorTests.class] pathForResource:archiveFilename ofType:nil];
  XCTAssert(archiveResPath, @"can't find %@", archiveFilename);
  
  NSString *tmpFilename = @"halfgig.data";
  NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename];
  
  BOOL worked = [LZMAExtractor extractArchiveEntry:archiveResPath archiveEntry:tmpFilename outPath:tmpPath];
  XCTAssert(worked, @"worked");
  
  // Note that it will not be possible to hold this massive file in memory or even map the whole file.
  // It can only be streamed from disk.
  
  BOOL exists = fileExists(tmpPath);
  XCTAssert(exists, @"exists");
  
  uint32_t size = filesize((char*)[tmpPath UTF8String]);
  
  NSLog(@"%@ : size %d", tmpFilename, size);
  
  // 500 megs
  
  XCTAssert(size == 1073741824/2, @"size");
  
  // Make sure to delete this massive file
  
  worked = [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
  XCTAssert(worked, @"worked");
  
  NSLog(@"DONE testHalfGig");
  
  return;
}

// This test attempts to extract a massive 1 gig file out of an archive, the file
// is so large that it cannot be held in regular memory on iOS. It also it too big
// to be held in virtual memory as a memory mapped file, so the only way that this
// file can be written to the disk is by streaming one buffer at a time. This test
// case basically checks the implementation of the SDK to verify that data is decoded
// and streamed to the disk as opposed to one massive malloc call that will fail
// on an embedded system. This test will pass on the Simulator, because MacOSX will
// automatically switch to virtual memory for a very large malloc.

- (void) testOneGigFailTooBig
{
  NSLog(@"START testOneGigFailTooBig");
  
  // This archive contains a 1 gigabyte file created like so:
  // 7za a -mx=9 onegig.7z onegig.data
  //
  // This should fail to decompress on an iOS device because the size of the vmem
  // mapping is larger than the maximum size allowed by the OS.
  //
  // The output of:
  //
  // 7za l -slt onegig.7z
  //
  // Shows that the entire one gig file was compressed down into 1 single block, so
  // there is no way for iOS to allocate a buffer that large.
  
  NSString *archiveFilename = @"onegig.7z";
  NSString *archiveResPath = [[NSBundle bundleForClass:LZMAExtractorTests.class] pathForResource:archiveFilename ofType:nil];
  XCTAssert(archiveResPath, @"can't find %@", archiveFilename);
  
  // Extract single entry "onegig.data" into the tmp dir
  
  NSString *tmpFilename = @"onegig.data";
  NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename];
  
  // Make sure file does not exist from some previous run at this point
  [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
  
  BOOL worked = [LZMAExtractor extractArchiveEntry:archiveResPath archiveEntry:tmpFilename outPath:tmpPath];
  
  if (TARGET_IPHONE_SIMULATOR) {
    XCTAssert(worked == TRUE, @"worked");
  } else {
    // Device, should fail
    XCTAssert(worked == FALSE, @"worked");
    
    BOOL exists = fileExists(tmpPath);
    XCTAssert(exists == FALSE, @"exists");
  }
  
  // Note that it will not be possible to hold this massive file in memory or even map the whole file.
  // It can only be streamed from disk.
  
  BOOL exists = fileExists(tmpPath);
  if (exists) {
    uint32_t size = filesize((char*)[tmpPath UTF8String]);
    
    NSLog(@"%@ : size %d", tmpFilename, size);
    
    // 1 gig
    
    XCTAssert(size == 1073741824, @"size");
    
    // Make sure to delete this massive file
    
    worked = [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
    XCTAssert(worked, @"worked");
  }
  
  NSLog(@"DONE testOneGigFailTooBig");
  return;
}

// This test will extract a pair of huge 650 meg files from a single archive.
// If both files were stored into 1 block, the mapping operation would fail
// on the device because the mapped size would be too large. But, one can work
// around the upper limit if absolutely required by encoding the archive
// with multiple blocks.
//
// Each block is decoded one at a time, so each file is able to fit into
// memory only one at a time. The key here is to pass these 680m arguments
// when encoding to define the upper limit of a block size, the result is
// that each file is contained in its own block.
//
// Create:
//
// 7za a -mx=9 -md=680m -ms=680m sixfiftymeg_2blocks.7z sixfiftymeg1.data sixfiftymeg2.data
//
// The output of:
//
// 7za l -slt sixfiftymeg_2blocks.7z
//
// Shows that two blocks are defined in the archive, each one contains one of the 650 meg files.

- (void) decodeSixFifty:(NSString*)entryName
{
  // Extract files from archive into named dir in the temp dir
  
  NSString *archiveFilename = @"sixfiftymeg_2blocks.7z";
  NSString *archiveResPath = [[NSBundle bundleForClass:LZMAExtractorTests.class] pathForResource:archiveFilename ofType:nil];
  XCTAssert(archiveResPath, @"can't find %@", archiveFilename);
  
  NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:entryName];
  
  BOOL worked = [LZMAExtractor extractArchiveEntry:archiveResPath archiveEntry:entryName outPath:tmpPath];
  XCTAssert(worked, @"worked");
  
  // Note that it will not be possible to hold this massive file in memory or even map the whole file.
  // It can only be streamed from disk.
  
  BOOL exists = fileExists(tmpPath);
  XCTAssert(exists, @"exists");
  
  uint32_t size = filesize((char*)[tmpPath UTF8String]);
  
  NSLog(@"%@ : size %d", entryName, size);
  
  // 650 megs
  
  XCTAssert(size == (1024 * 1024 * 650), @"size");
  
  // Delete the file on disk
  
  worked = [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
  XCTAssert(worked, @"worked");
  
  return;
}

- (void) testTwoSixFiftyInTwoBlocks
{
  NSLog(@"START testTwoSixFiftyInTwoBlocks");
  
  NSString *makeTmpFilename;
  makeTmpFilename = @"sixfiftymeg1.data";
  [self decodeSixFifty:makeTmpFilename];
  
  makeTmpFilename = @"sixfiftymeg2.data";
  [self decodeSixFifty:makeTmpFilename];
  
  NSLog(@"DONE testTwoSixFiftyInTwoBlocks");
}


@end
