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
#import "Divider.h"

@implementation DetailViewController

@synthesize detailViewDictionary, detailScrollView, detailMovie,detailSiteLink,detailCast, detailFilmTitle, detailID,
movieController;
#pragma mark - Initialize from Favorite or Regular
- (id)initWithNSDictionary:(id)detailDictionary loadFromCoreData:(BOOL)loadFaves withMovieController:(MovieController *)movieControl
{
    self = [super init];
    if (self){
        movieController = movieControl;
        needFaves = loadFaves;
        //Set vars...
        NSString *detailTitle;
        NSString *detailSynopsis;
        NSString *detailRated;
        NSString *detailFreshness;
        NSString *detailTime;
        NSString *detailHours;
        NSString *detailMins;
        // Set Dictionary for use in Object
        if (needFaves){
            detailMovie = (Movie *)detailDictionary;
            detailTitle = [detailMovie title];
            detailID = [[detailMovie id] stringValue];
            detailSynopsis = [detailMovie synopsis];
            detailCast = [detailMovie abridgedCast];
            detailSiteLink = [detailMovie siteLink];
            detailFilmTitle = [detailMovie title];
            detailTime = [detailMovie runtime];
            detailRated = [detailMovie mpaaRating];
            detailFreshness = [detailMovie criticsRating];
        }else{
            detailViewDictionary = (NSDictionary *)detailDictionary;
            detailTitle = [detailViewDictionary objectForKey:@"filmTitle"];
            detailID = [detailViewDictionary objectForKey:@"filmId"];
            detailCast = [detailViewDictionary objectForKey:@"abridgedCast"];
            detailSynopsis = [detailViewDictionary objectForKey:@"synopsis"];
            detailSiteLink= [detailViewDictionary objectForKey:@"siteLink"];
            detailFilmTitle = [detailViewDictionary objectForKey:@"filmTitle"];
            detailTime = [detailViewDictionary objectForKey:@"runtime"];
            detailRated = [detailViewDictionary objectForKey:@"mpaaRating"];
            detailFreshness = [detailViewDictionary objectForKey:@"criticsRating"];
        }

        if(([detailTime floatValue] / 60.0) > 1.0){
            float floatRuntime = ([detailTime floatValue] / 60.0);
            NSString *stringRuntime = [NSString stringWithFormat:@"%f",floatRuntime];
            NSArray *runtimeStringArray = [stringRuntime componentsSeparatedByString: @"."];
            detailHours = [runtimeStringArray objectAtIndex:0];
            NSLog(@"Runtime: %@hrs",detailHours);
            float amountToSubtract = [detailHours floatValue] * 60.0;
            float minutesRemainder = [detailTime floatValue] - amountToSubtract;
            NSArray *minutesStringArray = [[NSString stringWithFormat:@"%f",minutesRemainder] componentsSeparatedByString: @"."];
            detailMins = [NSString stringWithFormat:@"%@",[minutesStringArray objectAtIndex:0]];
        }else{
            detailHours = @"0";
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
        if (needFaves){
            getImagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Favorite"];
        }else{
            getImagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Temp"];
        }
        getImagePath = [getImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@-big.png",detailID]];
        UIImage *image = [UIImage imageWithContentsOfFile:getImagePath];
        UIImageView *posterImage = [[UIImageView alloc] initWithImage:image];        
        [posterImage setFrame:CGRectMake((fullScreenRect.size.width/2 - (posterImage.image.size.width/2)), padding, posterImage.image.size.width, posterImage.image.size.height)];
         NSLog(@"%f",(posterImage.image.size.width/2)
               );
        
        // Create Post to FB Button
        postButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[postButton setTitle:@"Post to Facebook" forState:UIControlStateNormal];
		postButton.frame = CGRectMake(90, posterImage.image.size.height + 20, 110, 29);
        postButton.enabled = NO;
        [postButton setAlpha:0.5];
        [postButton addTarget:self action:@selector(fbPost:) forControlEvents:UIControlEventTouchUpInside];
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
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([[delegate facebook] isSessionValid]) {
            [loginButton setAlpha:0.5];
            loginButton.enabled = NO;
        }
        // Add FB login button and Poster Iamge
        [detailScrollView addSubview:loginButton];
        [detailScrollView addSubview:posterImage];
        
        // Set Synopsis Header Label
        UIFont *defaultBoldFont = [UIFont boldSystemFontOfSize:14.0f];
        UILabel *synopsis = [[UILabel alloc] initWithFrame:CGRectMake(padding, posterImage.image.size.height + 50, 100,50)];
        [synopsis setBackgroundColor:[UIColor clearColor]];
        [synopsis setFont:defaultBoldFont];
        [synopsis setOpaque:NO];
        [synopsis setText:@"Synopsis"];
        CGSize synopsisSize = [synopsis.text sizeWithFont:defaultBoldFont];
        NSLog(@"Synopsis Label Size: %f",synopsisSize.height);
        
        // Set Synopsis Body Label
        UIFont *defaultNormalFont = [UIFont systemFontOfSize:14.0f];
        UILabel *synopsisText = [[UILabel alloc] init];
        [synopsisText setBackgroundColor:[UIColor clearColor]];
        [synopsisText setFont:defaultNormalFont];
        [synopsisText setOpaque:NO];
        synopsisText.lineBreakMode = UILineBreakModeWordWrap;
        synopsisText.numberOfLines = 0;
        NSString * synopsisLabelText = detailSynopsis;
        [synopsisText setText:synopsisLabelText];
        
        CGSize synopsisTextSize = [synopsisLabelText sizeWithFont:defaultNormalFont
                                    constrainedToSize:CGSizeMake(300.0f,CGFLOAT_MAX)
                                        lineBreakMode:UILineBreakModeWordWrap];
        [synopsisText setFrame:CGRectMake(padding, synopsis.frame.origin.y + synopsisSize.height + 20, 300.0f, synopsisTextSize.height)];
        
        
        // Add the labels
        [detailScrollView addSubview:synopsisText];
        [detailScrollView addSubview:synopsis];
        
        // Set Cast Header Label
        UILabel *castLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, synopsisText.frame.origin.y + synopsisText.frame.size.height + padding, 100,50)];
        [castLabel setBackgroundColor:[UIColor clearColor]];
        [castLabel setFont:defaultBoldFont];
        [castLabel setOpaque:NO];
        [castLabel setText:@"Cast"];
        CGSize castSize = [castLabel.text sizeWithFont:defaultBoldFont];
        NSLog(@"Cast Label Size: %f",castSize.height);
        
        float yCoordForCast = castLabel.frame.origin.y + castSize.height; 
        UIView *castView = [[UIView alloc] initWithFrame:CGRectMake(padding,yCoordForCast,300, 100)];
        int castIncrement = 1;
        float castViewResize = 0;
        for (NSDictionary* key in detailCast) {
            NSString * name = [key objectForKey:@"name"];
            id characters = [key objectForKey:@"characters"];
            NSString *characterString = [characters componentsJoinedByString: @", "];
            NSString *castLabelText = [NSString stringWithFormat:@"%@ as %@",name,characterString];
            NSLog(@"%@",castLabelText);
            CGSize castTextSize = [castLabelText sizeWithFont:defaultNormalFont forWidth:300.0f lineBreakMode:UILineBreakModeWordWrap];
            UILabel *castLabelTextContent = [[UILabel alloc] initWithFrame:CGRectMake(0,(castTextSize.height * castIncrement) + padding, 300,castTextSize.height)];
            castLabelTextContent.lineBreakMode = UILineBreakModeWordWrap;
            castLabelTextContent.numberOfLines = 0;
            castLabelTextContent.text = castLabelText;
            [castLabelTextContent setFont:defaultNormalFont];
            castViewResize = castViewResize + castTextSize.height + padding;
            [castLabelTextContent setBackgroundColor:[UIColor clearColor]];
            [castView addSubview:castLabelTextContent];
            castIncrement++;
        }
        NSLog(@"Cast View Resize: %f", castViewResize);
        [castView setFrame:CGRectMake(padding, yCoordForCast, 300, castViewResize)];
        
        Divider *dividerview = [[Divider alloc] initWithFrame:CGRectMake(padding, castView.frame.origin.y + castView.frame.size.height, 300, 3)];
        
        // Add the cast view
        [detailScrollView addSubview:castView];
        // Add the labels
        [detailScrollView addSubview:castLabel];
        // Add the divider
        [detailScrollView addSubview:dividerview];
        
        // Set Footer Header Label
        UIFont *footerNormalFont = [UIFont systemFontOfSize:11.0f];
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, dividerview.frame.origin.y + dividerview.frame.size.height - padding, 300,50)];
        [footerLabel setBackgroundColor:[UIColor clearColor]];
        footerLabel.lineBreakMode = UILineBreakModeWordWrap;
        footerLabel.numberOfLines = 0;
        [footerLabel setFont:footerNormalFont];
        [footerLabel setOpaque:NO];
        [footerLabel setText:[NSString stringWithFormat:@"Rated %@ • Freshness: %@  • Runtime: %@ hr %@ min",detailRated,detailFreshness,detailHours,detailMins]];
        CGSize footerLabelSize = [footerLabel.text sizeWithFont:footerNormalFont];
        NSLog(@"ratedLabel Size: %f",footerLabelSize.height);
        // Add the labels
        [detailScrollView addSubview:footerLabel];
        
        
        // Calculate scroll view size
        float sizeOfContent = 0;
        int i;
        for (i = 0; i < [detailScrollView.subviews count]; i++) {
            UIView *view =[detailScrollView.subviews objectAtIndex:i];
            sizeOfContent += view.frame.size.height;
        }
        
        // Set content size for scroll view
        detailScrollView.contentSize = CGSizeMake(detailScrollView.frame.size.width, sizeOfContent+60);
        
        // Add the scroll view
        [self.view addSubview:detailScrollView];
        
        
    }
    return self;
}
#pragma mark - Add to Favorite Button Clicked
- (void)addToFavorites:(id)sender{
    NSLog(@"Adding to Faves");
    [movieController setIdFavorite:detailID toValue:YES];
    faveButton.enabled = NO;
    [faveButton setTitle:@"Is a Favorite" forState:UIControlStateNormal];
    [faveButton setAlpha:0.5];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - Post message to Facebook
- (void)fbPost:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![[delegate facebook] isSessionValid]) {
        NSLog(@"Still not valid");
        
        [loginButton setAlpha:1];
        loginButton.enabled = YES;
    }else{
        NSLog(@"Session is valid");
        NSString *titleString = [[NSString alloc] initWithFormat:@"Check out: %@!!",detailFilmTitle];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"267983189936768", @"app_id",
                                       titleString, @"message",
                                       detailSiteLink, @"link",
                                       nil];
        [[delegate facebook] requestWithGraphPath:@"me/feed"
                                        andParams:params
                                    andHttpMethod:@"POST"
                                      andDelegate:self];
    }
}
#pragma mark - Login into Facebook
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
        [loginButton setAlpha:0.5];
        loginButton.enabled = NO;
        [postButton setAlpha:1.0];
        postButton.enabled = YES;
        
    } else {
        [loginButton setAlpha:0.5];
        loginButton.enabled = NO;
        [postButton setAlpha:1.0];
        postButton.enabled = YES;
    }
}
#pragma mark - Tweet Button CLicked
- (void)tweetLink:(id)sender
{
    
    // Create the view controller
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    
    
    // Optional: set an image, url and initial text
    [twitter addURL:[NSURL URLWithString:[NSString stringWithString:detailSiteLink]]];
    [twitter setInitialText:[NSString stringWithFormat:@"Check out: %@!!",detailFilmTitle]];
    
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
        [faveButton setAlpha:0.5];
    }else{
        NSLog(@"isnt fave");
        faveButton.enabled = YES;
        [faveButton setTitle:@"Click to Favorite" forState:UIControlStateNormal];
        [faveButton setAlpha:1.0];
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[delegate facebook] isSessionValid]) {
        NSLog(@"SESSION VALID");
        [loginButton setAlpha:0.5];
        loginButton.enabled = NO;
        [postButton setAlpha:1.0];
        postButton.enabled = YES;
    }else{
        NSLog(@"SESSION NOT VALID");
        [loginButton setAlpha:1];
        loginButton.enabled = YES;
    }
    [super viewWillAppear:animated];

}
- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"Screen APPEARED");
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
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Facebook Status Post"
                          message: @"Facebook Message Posted!"
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    NSLog(@"didLoad response");
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error message: %@", error);
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Facebook Status Post"
                          message: @"Facebook Message Didn't Posted! Please try again..."
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [loginButton setAlpha:1];
    loginButton.enabled = YES;
    [postButton setAlpha:0.5];
    postButton.enabled = NO;
}

@end
