//
//  ImageCache.h
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject
{
    
}

- (void) cacheImage: (NSString *) ImageURLString nameOfImage:(NSString *)nameString withExtension:(NSString *)extension;
- (void)createDirectoryIfNotExists;
- (void)createFavoriteDirectoryIfNotExists;
- (int)howManyDaysHavePast:(NSDate*)lastDate today:(NSDate*)today;

@end
