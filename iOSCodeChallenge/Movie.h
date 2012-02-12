//
//  Movie.h
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Movie : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * mpaaRating;
@property (nonatomic, retain) NSString * criticsScore;
@property (nonatomic, retain) NSString * criticsRating;
@property (nonatomic, retain) NSString * runtime;
@property (nonatomic, retain) NSString * synopsis;
@property (nonatomic, retain) NSString * thumbnailPoster;
@property (nonatomic, retain) id abridgedCast;
@property (nonatomic, retain) NSNumber * isFavorite;

@end
