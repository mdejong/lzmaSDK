//
//  lzmaSDKAppDelegate.m
//  lzmaSDK
//
//  Created by Moses DeJong on 11/30/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "lzmaSDKAppDelegate.h"

#import "LZMAExtractor.h"


// Return TRUE if file exists, FALSE otherwise

BOOL fileExists(NSString *filePath) {
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    return TRUE;
	} else {
    return FALSE;
  }
}

// Query open file size, then rewind to start

static
uint32_t filesize(char *filepath) {
  int retcode;
  FILE *fp = fopen(filepath, "r");
  retcode = fseek(fp, 0, SEEK_END);
  assert(retcode == 0);
  uint32_t size = ftell(fp);
  fclose(fp);
  return size;
}

@implementation lzmaSDKAppDelegate

@synthesize window;

// This test decodes a small text file from the attached resource test.7z
// This is a basic sanity check of the logic to decode an entry to a .7z archive.
// Because the input archive and output files are small, this test case will
// not use up much memory or emit large files.

- (void) testSmall
{
  BOOL worked;
  
  // Extract files from archive into named dir in the temp dir
  
	NSString *tmpDirname = @"Extract7z";
	NSString *archiveFilename = @"test.7z";
	NSString *archiveResPath = [[NSBundle mainBundle] pathForResource:archiveFilename ofType:nil];
  NSAssert(archiveResPath, @"can't find test.7z");
  
  NSArray *contents = [LZMAExtractor extract7zArchive:archiveResPath
                                           tmpDirName:tmpDirname];
  
  for (NSString *entryPath in contents) {
    NSData *outputData = [NSData dataWithContentsOfFile:entryPath];
    NSString *outStr = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    [outStr autorelease];
    
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
  
  if (worked) {
    NSData *outputData = [NSData dataWithContentsOfFile:makeTmpPath];
    NSString *outStr = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    [outStr autorelease];
    
    NSLog(@"%@", makeTmpFilename);
    NSLog(@"%@", outStr);
  }
}

// This test will extract a 500 meg file from testMed.7z, this 500 meg file is way too large
// to fit into regular memory, but it is smaller than the 700 meg limit on mapped memory
// in iOS. This method should work as long as the cached decoded data is written to a
// mapped file.

- (void) testMed
{
  // Extract files from archive into named dir in the temp dir
  
  NSString *make7zFilename = @"testMed.7z";
  NSString *make7zResPath = [[NSBundle mainBundle] pathForResource:make7zFilename ofType:nil];
  NSAssert(make7zResPath, @"can't find %@", make7zFilename);
  
  // Extract single entry "med.data" into the tmp dir
  
  NSString *makeTmpFilename = @"med.data";
  NSString *makeTmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:makeTmpFilename];
  
  BOOL worked = [LZMAExtractor extractArchiveEntry:make7zResPath archiveEntry:makeTmpFilename outPath:makeTmpPath];
  NSAssert(worked, @"worked");
  
  // Note that it will not be possible to hold this massive file in memory or even map the whole file.
  // It can only be streamed from disk.
  
  BOOL exists = fileExists(makeTmpPath);
  NSAssert(exists, @"exists");
  
  uint32_t size = filesize((char*)[makeTmpPath UTF8String]);
  
  NSLog(@"%@ : size %d", makeTmpFilename, size);
  
  // 500 megs

  NSAssert(size == 1073741824/2, @"size");
  
  // Make sure to delete this massive file
  
  worked = [[NSFileManager defaultManager] removeItemAtPath:makeTmpPath error:nil];
  NSAssert(worked, @"worked");
  
  return;
}

// This test attempts to extract a massive 1 gig file out of testBig.7z, the file
// is so large that it cannot be held in regular memory on iOS. It also it too big
// to be held in virtual memory as a memory mapped file, so the only way that this
// file can be written to the disk is by streaming one buffer at a time. This test
// case basically checks the implementation of the SDK to verify that data is decoded
// and streamed to the disk as opposed to one massive malloc call that will fail
// on an embedded system.

- (void) testBig
{
  // Extract files from archive into named dir in the temp dir
  
	NSString *make7zFilename = @"testBig.7z";
	NSString *make7zResPath = [[NSBundle mainBundle] pathForResource:make7zFilename ofType:nil];
  NSAssert(make7zResPath, @"can't find %@", make7zFilename);
  
  // Extract single entry "big.data" into the tmp dir
  
	NSString *makeTmpFilename = @"big.data";
	NSString *makeTmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:makeTmpFilename];
  
  BOOL worked = [LZMAExtractor extractArchiveEntry:make7zResPath archiveEntry:makeTmpFilename outPath:makeTmpPath];
  NSAssert(worked, @"worked");
  
  // Note that it will not be possible to hold this massive file in memory or even map the whole file.
  // It can only be streamed from disk.

  BOOL exists = fileExists(makeTmpPath);
  NSAssert(exists, @"exists");

  uint32_t size = filesize((char*)[makeTmpPath UTF8String]);
  
  NSLog(@"%@ : size %d", makeTmpFilename, size);

  // 1 gig
  
  NSAssert(size == 1073741824, @"size");
  
  // Make sure to delete this massive file
  
  worked = [[NSFileManager defaultManager] removeItemAtPath:makeTmpPath error:nil];
  NSAssert(worked, @"worked");
  
  return;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{  
  // Override point for customization after application launch
  [window makeKeyAndVisible];
  
  //[self testSmall];
  [self testMed];
  //[self testBig];

  NSLog(@"DONE");
  
  return;  
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
