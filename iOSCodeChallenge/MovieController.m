//
//  MovieController.m
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kRottenTomatoesURL [NSURL URLWithString: @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?limit=10&apikey=2cr36asnx786pgy52w8yfxph"] //2

#import "MovieController.h"

@implementation MovieController

@synthesize managedObjectContext, movieArray, delegate; 

- (id) init
{
    self = [super init];
    if (self){
        dispatch_async(kBgQueue, ^{
            NSLog(@"Asynchronous API request sent."); 
            NSData* data = [NSData dataWithContentsOfURL: kRottenTomatoesURL];
            [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        });
    }
    return self;
}

- (void)fetchedData:(NSData *)responseData {
    NSLog(@"Request complete. Handling data."); 
    //NSString *jsonData = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    
    movieArray = [[NSMutableArray alloc] initWithCapacity:10];
    NSError *parseError = nil;
    NSDictionary *json;
    @try 
    {
        json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&parseError];
    }
    @catch (NSException *exception) 
    {
        // Print exception information
        NSLog(@"NSException caught" );
        NSLog(@"Name: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);
        return;
    }

    NSArray* moviesJson = [json objectForKey:@"movies"];
    NSLog(@"%u",[moviesJson count]);
    
    for(int n = 0; n < [moviesJson count]; n = n + 1){

        NSDictionary* film = [moviesJson objectAtIndex:n];
        
        NSString* filmId = [film objectForKey:@"id"];
        NSString* filmTitle = [film objectForKey:@"title"];
        NSString* mpaaRating = [film objectForKey:@"mpaa_rating"];
        NSDictionary* ratings = [film objectForKey:@"ratings"];
        NSString* criticsScore = [ratings objectForKey:@"critics_score"];
        NSString* criticsRating = [ratings objectForKey:@"critics_rating"];
        NSString* runtime = [film objectForKey:@"runtime"];
        NSString* synopsis = [film objectForKey:@"synopsis"];
        NSDictionary* posters = [film objectForKey:@"posters"];
        NSDictionary* links = [film objectForKey:@"links"];
        NSDictionary* siteLink = [links objectForKey:@"alternate"];
        NSDictionary* abridgedCast = [film objectForKey:@"abridged_cast"];
        NSString* thumbnailPoster = [posters objectForKey:@"thumbnail"];
        NSString* detailedPoster = [posters objectForKey:@"detailed"];
        [self writeSmallImageToDirectory:thumbnailPoster andBigImageToDirectory:detailedPoster imageURLwithNameOf:filmId];
        //NSLog(@"%@",film);
        //NSLog(@"------------------------------");
        
        NSDictionary* currentMovie = [NSDictionary dictionaryWithObjectsAndKeys: 
                                        filmId, @"filmId",
                                        filmTitle, @"filmTitle",
                                        mpaaRating, @"mpaaRating",
                                        criticsScore, @"criticsScore",
                                        criticsRating, @"criticsRating",
                                        runtime, @"runtime",
                                        synopsis, @"synopsis",
                                        siteLink, @"siteLink",
                                        thumbnailPoster, @"thumbnailPoster",
                                        detailedPoster, @"detailedPoster",
                                        abridgedCast, @"abridgedCast",
                                        nil];
        [movieArray addObject:currentMovie];
    }
    NSLog(@"%d",[movieArray count]);
    [delegate movieListUpdated:movieArray];
}
-(void) writeSmallImageToDirectory:(NSString *)imageURL andBigImageToDirectory:(NSString *)bigImageURL imageURLwithNameOf:(NSString *)nameString
{
    //Small Image
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@-small.png",nameString]];
    [imageData writeToFile:imagePath atomically:YES];
    
    //Big Image
    NSURL *bigUrl = [NSURL URLWithString:bigImageURL];
    NSData *bigImageData = [NSData dataWithContentsOfURL:bigUrl];
    NSString *bigImagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@-big.png",nameString]];
    [bigImageData writeToFile:bigImagePath atomically:YES];
    
}
-(void) loadToCoreData:(NSDictionary *)dataToLoad
{
    
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Movie"
                inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
//    NSPredicate *predicate =
//    [NSPredicate predicateWithFormat:@"title == %@", filmTitle];
//    [request setPredicate:predicate];
    
    NSError *requestError = nil;
    NSUInteger numberOfRecords = [managedObjectContext countForFetchRequest:request error:&requestError];
    
    NSLog(@"Number of records %u", numberOfRecords);
    //[movieList setTitle: filmTitle]; 
    
    if (numberOfRecords == 0) {
        Movie *movieList = (Movie *)[NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:managedObjectContext];
        
        
    }
    else {
        // Deal with error.
    }
    
    NSError *error;
    
    if(![managedObjectContext save:&error]){
        
        NSLog(@"Your Managed Object blew its shit...");
        //This is a serious error saying the record
        //could not be saved. Advise the user to
        //try again or restart the application. 
        
    }
}
@end

@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
-(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}
@end