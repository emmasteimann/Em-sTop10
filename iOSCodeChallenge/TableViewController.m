//
//  TableViewController.m
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableViewController.h"
#import "DetailViewController.h"
#import "CustomMovieCell.h"

@implementation TableViewController

@synthesize tableArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
//- (id)initWithDataController:(MovieController *)movieController
//{
//    return self;
//}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UILabel *pullToReloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -30, 300, 20)];
//    pullToReloadLabel.text = @"Pull to Refresh";
//    [self.tableView addSubview:pullToReloadLabel];
    NSLog(@"Table view has launched.");
    tableArray = [[NSArray alloc] init];
    numberOfItems = [tableArray count];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
-(void) movieListUpdated: (NSArray *)movieArray
{
    tableArray = movieArray;
    numberOfItems = [tableArray count];
    [self.tableView reloadData];
}
- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryDisclosureIndicator;
}
//  --- Fun feature for later --- //
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    // Detect if the trigger has been set, if so add new items and reload
//    if (addItemsTrigger)
//    {
//        numberOfItems += 2;
//        NSLog(@"Scroll view reload");
//        self.title = @"Top 10";
//        [self.tableView reloadData];
//    }
//    // Reset the trigger
//    addItemsTrigger= NO;
//}
//- (void) scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    // Trigger the offset if the user has pulled back more than 50 points
//    if (scrollView.contentOffset.y < 0.0f)
//    {
//        self.title = @"Pull to Refresh";
//        if (scrollView.contentOffset.y < -50.0f)
//        {
//            addItemsTrigger = YES;
//            self.title = @"Let go! :)";
//        }
//    }
//}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return numberOfItems;
}
- (NSInteger)realRowNumberForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView 
{
	NSInteger retInt = 0;
	if (!indexPath.section)
	{
		return indexPath.row;
	}
    
	for (int i=0; i<indexPath.section;i++)
	{
		retInt += [tableView numberOfRowsInSection:i];
	}
	
	return retInt + indexPath.row;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger realRow = [self realRowNumberForIndexPath:indexPath inTableView:tableView];
	cell.backgroundColor = (realRow%2)?[UIColor whiteColor]:[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    NSLog(@"Populating list");
    static NSString *CellIdentifier = @"Cell";
    
    CustomMovieCell *cell = (CustomMovieCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomMovieCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *currentObject = [tableArray objectAtIndex: indexPath.row];
    NSLog(@"%@",[currentObject objectForKey:@"filmTitle"]);
    NSString *getImagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.png",[currentObject objectForKey:@"filmId"]]];
    UIImage *image = [UIImage imageWithContentsOfFile:getImagePath];
    
    [cell setMovieCellName:[NSString stringWithFormat:@"%@", [currentObject objectForKey:@"filmTitle"]] andMovieImage:image andCriticRatingValue:[currentObject objectForKey:@"criticsScore"] andMPAA:[currentObject objectForKey:@"mpaaRating"]];
    
    
    return cell;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 100.0;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = @"Go get some text for your cell.";
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:24.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 50;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    //NSDictionary *currentObject = [tableArray objectAtIndex: indexPath.row];
//    DetailViewController *detailViewController = [[DetailViewController alloc] initWithTitle:[[NSString alloc] initWithFormat:@"%@", [currentObject objectForKey:@"filmTitle"]]];
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNSDictionary:[tableArray objectAtIndex: indexPath.row]];
     // ...
     // Pass the selected object to the new view controller.

    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end