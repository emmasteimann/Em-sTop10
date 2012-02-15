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
        
        
        [posterImage setFrame:CGRectMake((fullScreenRect.size.width/2 - (posterImage.image.size.width/2)), 10, posterImage.image.size.width, posterImage.image.size.height)];
         NSLog(@"%f",(posterImage.image.size.width/2)
               );
        UIButton *postButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[postButton setTitle:@"Post to Facebook" forState:UIControlStateNormal];
		postButton.frame = CGRectMake(90, posterImage.image.size.height + 20, 110, 29);
        postButton.enabled = NO;
        [postButton setAlpha:0.5];
        postButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [detailScrollView addSubview:postButton];
        UIButton *faveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[faveButton setTitle:@"Click to Favorite" forState:UIControlStateNormal];
		faveButton.frame = CGRectMake(205, posterImage.image.size.height + 20, 110, 29);
        faveButton.enabled = NO;
        faveButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [detailScrollView addSubview:faveButton];
        // Login Button
        loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat xLoginButtonOffset = 10;
        CGFloat yLoginButtonOffset = posterImage.image.size.height + 20;
        loginButton.frame = CGRectMake(xLoginButtonOffset,yLoginButtonOffset,72,29);
        [loginButton addTarget:self
                        action:@selector(fbLogin:)
              forControlEvents:UIControlEventTouchUpInside];
        [loginButton setImage:
         [UIImage imageNamed:@"FBConnect.bundle/images/LoginNormal.png"]
                     forState:UIControlStateNormal];
        [loginButton setImage:
         [UIImage imageNamed:@"FBConnect.bundle/images/LoginPressed.png"]
                     forState:UIControlStateHighlighted];
        [loginButton sizeToFit];
        [detailScrollView addSubview:loginButton];
        
        [detailScrollView addSubview:posterImage];
        UIFont *defaultFont = [UIFont boldSystemFontOfSize:14.0f];
        UILabel *synopsis = [[UILabel alloc] initWithFrame:CGRectMake(10, posterImage.image.size.height + 50, 100,50)];
        [synopsis setBackgroundColor:[UIColor clearColor]];
        [synopsis setFont:defaultFont];
        [synopsis setOpaque:NO];
        [synopsis setText:@"Synopsis"];
        
        UILabel *synopsisText = [[UILabel alloc] initWithFrame:CGRectMake(10, posterImage.image.size.height + 80, 300,200)];
        [synopsisText setBackgroundColor:[UIColor clearColor]];
        [synopsisText setFont:defaultFont];
        [synopsisText setOpaque:NO];
        synopsisText.lineBreakMode = UILineBreakModeWordWrap;
        synopsisText.numberOfLines = 0;
        NSString * synopsisLabelText = [detailViewDictionary objectForKey:@"synopsis"];
        [synopsisText setText:synopsisLabelText];
        
        [detailScrollView addSubview:synopsisText];
        [detailScrollView addSubview:synopsis];
        
        CGSize size = [synopsisLabelText sizeWithFont:defaultFont
                                    constrainedToSize:CGSizeMake(300.0f,CGFLOAT_MAX)
                                        lineBreakMode:UILineBreakModeWordWrap];
        NSLog(@"%@",synopsisLabelText);
        NSLog(@"%f",size.height);
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
    //    UIFont *myFont = [UIFont boldSystemFontOfSize:15.0];
    //    
    //    // Get the width of a string when wrapping within a particular width
    //    NSString *loremIpsum = @"Lorem Ipsum Delores S...";
    //    CGSize size = [loremIpsum sizeWithFont:myFont
    //                                  forWidth:150.0 
    //                             lineBreakMode:UILineBreakModeWordWrap];
    //    NSLog(@"%f",size.height);
    //    NSLog(@"%f",size.width);

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
