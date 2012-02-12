//
//  TableViewController.h
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieController.h"

@interface TableViewController : UITableViewController <MovieControllerDelegate>
{
    int numberOfItems;
    BOOL addItemsTrigger;
    NSArray *tableArray;
}

@property (nonatomic, retain) NSArray *tableArray; 

@end
