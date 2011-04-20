//
//  lzmaSDKAppDelegate.m
//  lzmaSDK
//
//  Created by Moses DeJong on 11/30/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "lzmaSDKAppDelegate.h"

#import "LZMAExtractor.h"

@implementation lzmaSDKAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  
  // Override point for customization after application launch
  [window makeKeyAndVisible];
  
  // Extract files from archive into named dir in the temp dir
  
	NSString *tmpDirname = @"Extract7z";
	NSString *make7zFilename = @"test.7z";
	NSString *make7zResPath = [[NSBundle mainBundle] pathForResource:make7zFilename ofType:nil];
  NSAssert(make7zResPath, @"can't find test.7z");
  
  NSArray *contents = [LZMAExtractor extract7zArchive:make7zResPath tmpDirName:tmpDirname];
  
  for (NSString *entryPath in contents) {
    NSData *outputData = [NSData dataWithContentsOfFile:entryPath];
    NSString *outStr = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    [outStr autorelease];
    
    NSLog(@"%@", entryPath);
    NSLog(@"%@", outStr);
  }
  
  // Extract single entry "make.out" and save it as "tmp/make.out.txt" in the tmp dir.
  
	NSString *makeTmpFilename = @"make.out.txt";
	NSString *makeTmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:makeTmpFilename];
  
  BOOL worked = [LZMAExtractor extractArchiveEntry:make7zResPath archiveEntry:@"make.out" outPath:makeTmpPath];
  
  if (worked) {
    NSData *outputData = [NSData dataWithContentsOfFile:makeTmpPath];
    NSString *outStr = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    [outStr autorelease];
    
    NSLog(@"%@", makeTmpFilename);
    NSLog(@"%@", outStr);    
  }

  NSLog(@"DONE");
  
  return;  
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
