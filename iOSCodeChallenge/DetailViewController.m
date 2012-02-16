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
#import "Movie.h"
#import "MovieController.h"

@implementation DetailViewController

@synthesize detailViewDictionary, detailScrollView, detailMovie, detailID,
movieController;

- (id)initWithNSDictionary:(id)detailDictionary loadFromCoreData:(BOOL)loadFaves withMovieController:(MovieController *)movieControl
{
    self = [super init];
    if (self){
        movieController = movieControl;
        needFaves = loadFaves;
        //Set vars...
        NSString *detailTitle;
        NSString *detailSynopsis;
        
        // Set Dictionary for use in Object
        if (needFaves){
            detailMovie = (Movie *)detailDictionary;
            detailTitle = [detailMovie title];
            detailID = [[detailMovie id] stringValue];
            detailSynopsis = [detailMovie synopsis];
        }else{
            detailViewDictionary = (NSDictionary *)detailDictionary;
            detailTitle = [detailViewDictionary objectForKey:@"filmTitle"];
            detailID = [detailViewDictionary objectForKey:@"filmId"];
            detailSynopsis = [detailViewDictionary objectForKey:@"synopsis"];
        }
        
            
        // Set title for View
        self.title = detailTitle;
        
        // Set up Tweet Button
        UIBarButtonItem *navigationBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(tweetLink:)];
        
        self.navigationItem.rightBarButtonItem = navigationBackButton;
        
        // Setup Scroll View
        CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
        
        detailScrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
        
        detailScrollView.contentSize=CGSizeMake(fullScreenRect.size.width,758);
        [detailScrollView setFrame:CGRectMake(0, 0, fullScreenRect.size.width, fullScreenRect.size.height)];
        float padding = 10.0;
        
        // Get and Create Poster Iamge
        NSString *getImagePath;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        getImagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Temp"];
        getImagePath = [getImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@-big.png",detailID]];
        UIImage *image = [UIImage imageWithContentsOfFile:getImagePath];
        UIImageView *posterImage = [[UIImageView alloc] initWithImage:image];        
        [posterImage setFrame:CGRectMake((fullScreenRect.size.width/2 - (posterImage.image.size.width/2)), padding, posterImage.image.size.width, posterImage.image.size.height)];
         NSLog(@"%f",(posterImage.image.size.width/2)
               );
        
        // Create Post to FB Button
        UIButton *postButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[postButton setTitle:@"Post to Facebook" forState:UIControlStateNormal];
		postButton.frame = CGRectMake(90, posterImage.image.size.height + 20, 110, 29);
        postButton.enabled = NO;
        [postButton setAlpha:0.5];
        postButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [detailScrollView addSubview:postButton];
        
        // Create Fave Button
        faveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[faveButton setTitle:@"Click to Favorite" forState:UIControlStateNormal];
		faveButton.frame = CGRectMake(205, posterImage.image.size.height + 20, 110, 29);
        ///faveButton.enabled = NO;
        faveButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [faveButton addTarget:self action:@selector(addToFavorites:) forControlEvents:UIControlEventTouchUpInside];
        // Add Fave Button 
        [detailScrollView addSubview:faveButton];
        
        // Create FB Login Button
        loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat xLoginButtonOffset = padding;
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
        
        // Add FB login button and Poster Iamge
        [detailScrollView addSubview:loginButton];
        [detailScrollView addSubview:posterImage];
        
        // Set Synopsis Header Label
        UIFont *defaultFont = [UIFont boldSystemFontOfSize:14.0f];
        UILabel *synopsis = [[UILabel alloc] initWithFrame:CGRectMake(padding, posterImage.image.size.height + 50, 100,50)];
        [synopsis setBackgroundColor:[UIColor clearColor]];
        [synopsis setFont:defaultFont];
        [synopsis setOpaque:NO];
        [synopsis setText:@"Synopsis"];
        CGSize synopsisSize = [synopsis.text sizeWithFont:defaultFont];
        NSLog(@"Synopsis Label Size: %f",synopsisSize.height);
        
        // Set Synopsis Body Label
        UILabel *synopsisText = [[UILabel alloc] init];
        [synopsisText setBackgroundColor:[UIColor clearColor]];
        [synopsisText setFont:defaultFont];
        [synopsisText setOpaque:NO];
        synopsisText.lineBreakMode = UILineBreakModeWordWrap;
        synopsisText.numberOfLines = 0;
        NSString * synopsisLabelText = detailSynopsis;
        [synopsisText setText:synopsisLabelText];
        
        CGSize synopsisTextSize = [synopsisLabelText sizeWithFont:defaultFont
                                    constrainedToSize:CGSizeMake(300.0f,CGFLOAT_MAX)
                                        lineBreakMode:UILineBreakModeWordWrap];
        [synopsisText setFrame:CGRectMake(padding, synopsis.frame.origin.y + synopsisSize.height + 20, 300.0f, synopsisTextSize.height)];
        
        
        // Add the labels
        [detailScrollView addSubview:synopsisText];
        [detailScrollView addSubview:synopsis];
        
        
        
        
        
        
        // Add the scroll view
        [self.view addSubview:detailScrollView];
        
        
    }
    return self;
}
- (void)addToFavorites:(id)sender{
    NSLog(@"Adding to Faves");
    [movieController setIdFavorite:detailID toValue:YES];
    faveButton.enabled = NO;
    [faveButton setTitle:@"Is a Favorite" forState:UIControlStateNormal];
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
    //Set vars...
    NSString *detailSiteLink;
    NSString *detailFilmTitle;
    
    // Set Dictionary for use in Object
    if (needFaves){
        detailSiteLink = [detailMovie siteLink];
        detailFilmTitle = [detailMovie title];
    }else{
        detailSiteLink= [detailViewDictionary objectForKey:@"siteLink"];
        detailFilmTitle = [detailViewDictionary objectForKey:@"filmTitle"];
    }
    
    // Create the view controller
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    
    
    // Optional: set an image, url and initial text
    [twitter addURL:[NSURL URLWithString:[NSString stringWithString:detailSiteLink]]];
    [twitter setInitialText:[NSString stringWithFormat:@"Check out: %@!!",detailFilmTitle,detailSiteLink]];
    
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
- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"DETAIL _ _ _ APPPPEEEEEAAAARRRREEEDD");
    BOOL isFavoriteItem = [movieController checkIfFavorite:detailID];
    if(isFavoriteItem){
        NSLog(@"is fave");
        faveButton.enabled = NO;
        [faveButton setTitle:@"Is a Favorite" forState:UIControlStateNormal];
    }else{
        NSLog(@"isnt fave");
        faveButton.enabled = YES;
        [faveButton setTitle:@"Click to Favorite" forState:UIControlStateNormal];
    }
    
    [super viewWillAppear:animated];

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
