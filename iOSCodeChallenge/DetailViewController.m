//
//  DetailViewController.m
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "AppDelegate.h"
#import "DetailViewController.h"
#import <Twitter/Twitter.h>
#import "ImageCache.h"

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
        
        detailScrollView.contentSize=CGSizeMake(fullScreenRect.size.width,758);
        [detailScrollView setFrame:CGRectMake(0, 0, fullScreenRect.size.width, fullScreenRect.size.height)];
        
        NSString *getImagePath;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        getImagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Temp"];
        getImagePath = [getImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@-big.png",[detailViewDictionary objectForKey:@"filmId"]]];
        
        
        UIImage *image = [UIImage imageWithContentsOfFile:getImagePath];
        
        UIImageView *posterImage = [[UIImageView alloc] initWithImage:image];
        
        
        [posterImage setFrame:CGRectMake((fullScreenRect.size.width/2 - (posterImage.image.size.width/2)), 50, posterImage.image.size.width, posterImage.image.size.height)];
         NSLog(@"%f",(posterImage.image.size.width/2)
               );
        
        // Login Button
        loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat xLoginButtonOffset = self.view.center.x - (318/2);
        CGFloat yLoginButtonOffset = self.view.bounds.size.height - (58 + 13);
        loginButton.frame = CGRectMake(xLoginButtonOffset,yLoginButtonOffset,318,58);
        [loginButton addTarget:self
                        action:@selector(fbLogin:)
              forControlEvents:UIControlEventTouchUpInside];
        [loginButton setImage:
         [UIImage imageNamed:@"FBConnect.bundle/images/LoginWithFacebookNormal@2x.png"]
                     forState:UIControlStateNormal];
        [loginButton setImage:
         [UIImage imageNamed:@"FBConnect.bundle/images/LoginWithFacebookPressed@2x.png"]
                     forState:UIControlStateHighlighted];
        [loginButton sizeToFit];
        [detailScrollView addSubview:loginButton];
        
        [detailScrollView addSubview:posterImage];
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
- (void)fbLogin:(id)sender
{
    NSLog(@"w00t");
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![[delegate facebook] isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"publish_stream", 
                                @"read_stream",
                                nil];
        [[delegate facebook] authorize:permissions];
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"267983189936768", @"app_id",
                                       @"Meow test",@"message",
                                       nil];
        [[delegate facebook] requestWithGraphPath:@"me/feed"
                                        andParams:params
                                    andHttpMethod:@"POST"
                                      andDelegate:self];
    }
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
#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }
    
    NSLog(@"didLoad response");
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error message: %@", error);
}

@end
