//
//  DetailViewController.h
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface DetailViewController : UIViewController <FBRequestDelegate>
{
    NSDictionary *detailViewDictionary;
    UIScrollView *detailScrollView;
    UIButton *loginButton;
}

- (id)initWithNSDictionary:(NSDictionary *)detailDictionary;

@property (nonatomic, retain) NSDictionary *detailViewDictionary;
@property (nonatomic, retain) UIScrollView *detailScrollView;

@end
