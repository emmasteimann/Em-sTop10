//
//  ImageCache.m
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageCache.h"

#define tempDirectory @"Temp"
#define faveDirectory @"Favorite"
#define daysToLive 2

@implementation ImageCache
- (id)init
{
    self = [super init];
    if (self){
        [self createDirectoryIfNotExists];
        [self createFavoriteDirectoryIfNotExists];
    }
    return self;
}
- (void)createFavoriteDirectoryIfNotExists{
    
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:faveDirectory];
	NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory already exist?
	{
        NSLog(@"Creating temp directory...");
		if (![[NSFileManager defaultManager] createDirectoryAtPath:path
									   withIntermediateDirectories:NO
														attributes:nil
															 error:&error])
		{
			NSLog(@"Create directory error: %@", error);
		}
	} else {
        NSLog(@"Directory Exists...");
        return;
    }
}
- (void)createDirectoryIfNotExists{
   
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:tempDirectory];
	NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory already exist?
	{
         NSLog(@"Creating temp directory...");
		if (![[NSFileManager defaultManager] createDirectoryAtPath:path
									   withIntermediateDirectories:NO
														attributes:nil
															 error:&error])
		{
			NSLog(@"Create directory error: %@", error);
		}
	} else {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                 error:nil];
        NSDate* dateCreated = [attributes objectForKey:NSFileCreationDate];
        NSLog(@"%@",dateCreated);
        int daysOld = [self howManyDaysHavePast:dateCreated today:[NSDate date]];
        NSLog(@"Folder is %i days old",daysOld);
        if(daysOld > daysToLive){
            NSLog(@"Deleting directory, as its %i days old.", daysOld);
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:nil])	//Delete it
            {
                NSLog(@"Delete directory error: %@", error);
            }
            NSLog(@"Recreating...");
            if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                           withIntermediateDirectories:NO
                                                            attributes:nil
                                                                 error:&error])
            {
                NSLog(@"Create directory error: %@", error);
            }
        }
    }
}

- (void) cacheImage: (NSString *) ImageURLString nameOfImage:(NSString *)nameString withExtension:(NSString *)extension
{
    NSLog(@"Cache method launched...");
    
    NSURL *ImageURL = [NSURL URLWithString: ImageURLString];
    
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:tempDirectory];
    
    NSString *uniquePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.png",nameString,extension]];
    
    // Check for file existence
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        NSLog(@"File does not exist, writing...");
        NSData *imageData = [NSData dataWithContentsOfURL:ImageURL];
        [imageData writeToFile:uniquePath atomically:YES];

    }
}
-(int)howManyDaysHavePast:(NSDate*)lastDate today:(NSDate*)today {
	NSDate *startDate = lastDate;
	NSDate *endDate = today;
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSDayCalendarUnit;
	NSDateComponents *components = [gregorian components:unitFlags
												fromDate:startDate
												  toDate:endDate options:0];
	int days = [components day];
	return days;
}
@end
