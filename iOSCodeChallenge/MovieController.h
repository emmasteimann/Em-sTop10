//
//  MovieController.h
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"

@interface MovieController : NSObject
{
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *movieArray;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *movieArray; 

@end
