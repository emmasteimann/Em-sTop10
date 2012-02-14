//
//  AppDelegate.h
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate> 
{
    Facebook *facebook;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;
@property (readonly, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
