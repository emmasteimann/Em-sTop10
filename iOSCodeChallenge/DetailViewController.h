//
//  DetailViewController.h
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
{
    NSDictionary *detailViewDictionary;
    UIScrollView *detailScrollView;
}

- (id)initWithNSDictionary:(NSDictionary *)detailDictionary;

@property (nonatomic, retain) NSDictionary *detailViewDictionary;
@property (nonatomic, retain) UIScrollView *detailScrollView;

@end
