//
//  lzmaSDKAppDelegate.m
//  lzmaSDK
//
//  Created by Moses DeJong on 11/30/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "lzmaSDKAppDelegate.h"

extern int do7z_extract_files(char *archive_name);

@implementation lzmaSDKAppDelegate

@synthesize window;

// Extract the contents of a .7z archive into the indicated temp dir
// and return an array of the fully qualified filenames.

- (NSArray*) extract7zArchive:(NSString*)archivePath tmpDirName:(NSString*)tmpDirName {    
	NSString *tmpDir = NSTemporaryDirectory();    
    BOOL worked, isDir, existsAlready;
    
    NSString *myTmpDir = [tmpDir stringByAppendingPathComponent:tmpDirName];
    existsAlready = [[NSFileManager defaultManager] fileExistsAtPath:myTmpDir isDirectory:&isDir];
    
    if (existsAlready && !isDir) {
        worked = [[NSFileManager defaultManager] removeItemAtPath:myTmpDir error:nil];
        NSAssert(worked, @"could not remove existing file with same name as tmp dir");
        // create the directory below
    }
    
    if (existsAlready && isDir) {
        // Remove all the files in the named tmp dir
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:myTmpDir error:nil];
        NSAssert(contents, @"contentsOfDirectoryAtPath failed");
        for (NSString *path in contents) {
            NSLog([NSString stringWithFormat:@"found existing dir path: %@", path]);
            NSString *myTmpDirPath = [myTmpDir stringByAppendingPathComponent:path];
            worked = [[NSFileManager defaultManager] removeItemAtPath:myTmpDirPath error:nil];
            NSAssert(worked, @"could not remove existing file");
        }
    } else {
        worked = [[NSFileManager defaultManager] createDirectoryAtPath:myTmpDir attributes:nil];
        NSAssert(worked, @"could not create tmp dir");
    }
    
    worked = [[NSFileManager defaultManager] changeCurrentDirectoryPath:myTmpDir];
    NSAssert(worked, @"cd to tmp 7z dir failed");
    NSLog([NSString stringWithFormat:@"cd to %@", myTmpDir]);
    
    char *path = (char*) [archivePath UTF8String];
    int result = do7z_extract_files(path);
    NSAssert(result == 0, @"could not extract files from 7z archive");
    
    // Examine the contents of the current directory to see what was extracted
    
    NSMutableArray *fullPathContents = [NSMutableArray array];
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:myTmpDir error:nil];
    NSAssert(contents, @"contentsOfDirectoryAtPath failed");
    for (NSString *path in contents) {
        NSLog([NSString stringWithFormat:@"found existing dir path: %@", path]);
        NSString *myTmpDirPath = [myTmpDir stringByAppendingPathComponent:path];
        [fullPathContents addObject:myTmpDirPath];
    }
    
    return [NSArray arrayWithArray:fullPathContents];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];

    // Extract files from archive into named dir in the temp dir

	NSString *tmpDirname = @"Extract7z";
	NSString *make7zFilename = @"make.7z";
	NSString *make7zResPath = [[NSBundle mainBundle] pathForResource:make7zFilename ofType:nil];

    NSArray *contents = [self extract7zArchive:make7zResPath tmpDirName:tmpDirname];

    for (NSString *entryPath in contents) {
        NSData *outputData = [NSData dataWithContentsOfFile:entryPath];
        NSString *outStr = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        [outStr autorelease];
        
        NSLog(entryPath);
        NSLog(outStr);
    }
    
    return;
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
