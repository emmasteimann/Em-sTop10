//
//  DetailViewController.m
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import <Twitter/Twitter.h>

@implementation DetailViewController

@synthesize detailViewDictionary, detailScrollView;

- (id)initWithNSDictionary:(NSDictionary *)detailDictionary
{
    self = [super init];
    if (self){
        detailViewDictionary = detailDictionary;
        self.title = [detailViewDictionary objectForKey:@"filmTitle"];
        UIBarButtonItem *navigationBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(tweetLink:)];
        self.navigationItem.rightBarButtonItem = navigationBackButton;
        CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
        detailScrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
        detailScrollView.contentSize=CGSizeMake(320,758);
        [self.view addSubview:detailScrollView];
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)tweetLink:(id)sender
{
    // Create the view controller
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    
    // Optional: set an image, url and initial text
    [twitter addURL:[NSURL URLWithString:[NSString stringWithString:[detailViewDictionary objectForKey:@"siteLink"]]]];
    [twitter setInitialText:[NSString stringWithFormat:@"Check out: %@!!",[detailViewDictionary objectForKey:@"filmTitle"],[detailViewDictionary objectForKey:@"siteLink"]]];
    
    // Show the controller
    [self presentModalViewController:twitter animated:YES];
    
    // Called when the tweet dialog has been closed
    twitter.completionHandler = ^(TWTweetComposeViewControllerResult result) 
    {
        NSString *title = @"Tweet Status";
        NSString *msg; 
        
        if (result == TWTweetComposeViewControllerResultCancelled)
            msg = @"Tweet compostion was canceled.";
        else if (result == TWTweetComposeViewControllerResultDone)
            msg = @"Tweet composition completed.";
        
        // Show alert to see how things went...
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        
        // Dismiss the controller
        [self dismissModalViewControllerAnimated:YES];
    };
}
#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    //self.title = @"Detail";
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
