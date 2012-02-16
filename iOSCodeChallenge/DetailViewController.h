//
//  DetailViewController.h
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "Movie.h"
#import "MovieController.h"

@interface DetailViewController : UIViewController <FBRequestDelegate>
{
    NSDictionary *detailViewDictionary;
    Movie *detailMovie;
    MovieController *movieController;
    NSString *detailID;
    UIScrollView *detailScrollView;
    UIButton *loginButton;
    UIButton *faveButton;
    UIButton *postButton;
    NSDictionary *detailCast;
    NSString *detailSiteLink;
    NSString *detailFilmTitle;
    BOOL needFaves;
}

- (id)initWithNSDictionary:(id)detailDictionary loadFromCoreData:(BOOL)loadFaves withMovieController:(MovieController *)movieControl;

@property (nonatomic, retain) MovieController *movieController;
@property (nonatomic, retain) NSString *detailID;
@property (nonatomic, retain) NSDictionary *detailViewDictionary;
@property (nonatomic, retain) Movie *detailMovie;
@property (nonatomic, retain) UIScrollView *detailScrollView;
@property (nonatomic, retain) NSString *detailSiteLink;
@property (nonatomic, retain) NSString *detailFilmTitle;
@property (nonatomic, retain) NSDictionary *detailCast;
@end
