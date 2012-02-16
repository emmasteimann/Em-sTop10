//
//  TableViewController.h
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieController.h"
#import "Movie.h"

@interface TableViewController : UITableViewController <MovieControllerDelegate>
{
    int numberOfItems;
    BOOL addItemsTrigger;
    NSArray *tableArray;
    BOOL needFavorites;
    MovieController *myFavorites;
    Movie *currentMovie;
}

- (id)initWithFavorites:(MovieController *)fave;
- (void)loadFavorites;
- (id)initWithMovieController:(MovieController *)movieController;

@property (nonatomic, retain) NSArray *tableArray; 
@property (nonatomic, retain) Movie *currentMovie;
@property (nonatomic, retain) MovieController *myFavorites; 

@end
