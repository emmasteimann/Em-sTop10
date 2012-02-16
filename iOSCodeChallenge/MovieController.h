//
//  MovieController.h
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"
#import "ImageCache.h"

@protocol MovieControllerDelegate

@optional

-(void) movieListUpdated: (NSArray *)movieArray;

@end

@interface MovieController : NSObject
{
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *movieArray;
    NSString *movieListString;
    id<MovieControllerDelegate> delegate;
    ImageCache *imageCache;
}
- (id) initWithImageCache:(ImageCache *)appImageCache;
-(void) writeSmallImageToDirectory:(NSString *)imageURL andBigImageToDirectory:(NSString *)bigImageURL imageURLwithNameOf:(NSString *)nameString;
-(void) loadToCoreData:(NSDictionary *)dataToLoad;
- (NSMutableArray*)getMoviesFromCoreData;
- (void)setMovieFavorite:(Movie *)movieToSet toValue:(BOOL)value;
- (void)setIdFavorite:(NSString *)movieToSet toValue:(BOOL)value;
-(BOOL)checkIfFavorite:(NSString *)movieId;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *movieArray; 
@property (nonatomic, retain) id<MovieControllerDelegate> delegate;
@property (nonatomic, retain) ImageCache *imageCache;

@end
