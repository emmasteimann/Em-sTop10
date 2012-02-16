//
//  MovieController.m
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kRottenTomatoesURL [NSURL URLWithString: @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?limit=10&apikey=2cr36asnx786pgy52w8yfxph"] //2
#define tempDirectory @"Temp"
#define faveDirectory @"Favorite"

#import "MovieController.h"

@implementation MovieController

@synthesize managedObjectContext, movieArray, delegate, imageCache; 

- (id) initWithImageCache:(ImageCache *)appImageCache;
{
    self = [super init];
    if (self){
        imageCache = appImageCache;
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
        [self loadToCoreData:currentMovie];
        [movieArray addObject:currentMovie];
    }
    NSLog(@"%d",[movieArray count]);
    [delegate movieListUpdated:movieArray];
}
-(void) writeSmallImageToDirectory:(NSString *)imageURL andBigImageToDirectory:(NSString *)bigImageURL imageURLwithNameOf:(NSString *)nameString
{
    //Small Image
    [imageCache cacheImage:imageURL nameOfImage:nameString withExtension:@"small"];
    
    //Big Image
    [imageCache cacheImage:bigImageURL nameOfImage:nameString withExtension:@"big"];
    
}
-(void) loadToCoreData:(NSDictionary *)dataToLoad
{
    NSEntityDescription *entity;
    @try 
    {
        entity =
        [NSEntityDescription entityForName:@"Movie"
                    inManagedObjectContext:managedObjectContext];
    }
    @catch (NSException *exception) 
    {
        // Print exception information
        NSLog(@"NSException caught" );
        NSLog(@"Name: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);
        return;
    }
    
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"id == %@", [dataToLoad objectForKey:@"filmId"]];
    [request setPredicate:predicate];
    
    NSError *requestError = nil;
    NSUInteger numberOfRecords = [managedObjectContext countForFetchRequest:request error:&requestError];
    
    NSLog(@"Number of records %u", numberOfRecords);
    //[movieList setTitle: filmTitle]; 
    
    if (numberOfRecords == 0) {
        NSLog(@"No records found!");
        
        Movie *movieList = (Movie *)[NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:managedObjectContext];
        
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *movieId = [f numberFromString:[dataToLoad objectForKey:@"filmId"]];
        [movieList setId: movieId];
        [movieList setAbridgedCast: [dataToLoad objectForKey:@"abridgedCast"]];
        [movieList setCriticsRating: [dataToLoad objectForKey:@"criticsRating"]];
        [movieList setMpaaRating: [dataToLoad objectForKey:@"mpaaRating"]];
        [movieList setSynopsis: [dataToLoad objectForKey:@"synopsis"]];
        [movieList setThumbnailPoster: [dataToLoad objectForKey:@"thumbnailPoster"]];
        [movieList setTitle: [dataToLoad objectForKey:@"filmTitle"]];
        [movieList setCriticsScore: [[NSString alloc] initWithFormat:@"%@",[dataToLoad objectForKey:@"criticsScore"]]];
        [movieList setRuntime: [[NSString alloc] initWithFormat:@"%@",[dataToLoad objectForKey:@"runtime"]]];
        [movieList setDetailedPoster: [dataToLoad objectForKey:@"detailedPoster"]];
        [movieList setSiteLink: [dataToLoad objectForKey:@"siteLink"]];
        
        NSError *error = nil;
        [managedObjectContext save:&error];
        
        if (error) {
            NSLog(@"[ERROR] COREDATA: Save raised an error - '%@'", [error description]);
            return;
        }
        
        NSLog(@"[SUCCESS] COREDATA: Inserted new product to database!");
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

- (NSMutableArray*)getMoviesFromCoreData {
	
    NSLog(@"Checking for favorites");
    
	NSEntityDescription *entity;
    @try 
    {
        entity =
        [NSEntityDescription entityForName:@"Movie"
                    inManagedObjectContext:managedObjectContext];
    }
    @catch (NSException *exception) 
    {
        // Print exception information
        NSLog(@"NSException caught" );
        NSLog(@"Name: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);
        return movieArray;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"isFavorite == %i", 1];
    [request setPredicate:predicate];
    
	NSError *error = nil;
	NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
	
	if (!results || error) {
		NSLog(@"[ERROR] COREDATA: Fetch request raised an error - '%@'", [error description]);
		return movieArray;
	}
	
	if (movieArray) {
		movieArray = nil;
	}
	
	movieArray = [[NSMutableArray alloc] initWithArray: results];
    
    NSLog(@"grabbing from core data");
    for (id theCoreDataObject in results) {
        NSLog(@"Query returned %@", 
              theCoreDataObject); 
    }
    NSLog(@"%@",results);
	NSLog(@"%@",movieArray);
    return movieArray;
}
- (void)setMovieFavorite:(Movie *)movieToSet toValue:(BOOL)value {
    
	NSLog(@"****************************************");
    NSLog(@"Set IS FAVE BY MOVIEEEEE");
    NSLog(@"****************************************");
    
	[movieToSet setIsFavorite:[NSNumber numberWithBool:value]];
	
	NSError *error = nil;
	[managedObjectContext save:&error];
	
	if (error) {
		NSLog(@"[ERROR] COREDATA: Save raised an error - '%@'", [error description]);
		return;
	}
		
	NSLog(@"[SUCCESS] COREDATA: Updated product in database!");
    
    // Handle Moving Files
    if(!value){        
        NSLog(@"****************************************");
        NSLog(@"MOVING File...");
        NSLog(@"****************************************");
        NSString *nameString = [[movieToSet id] stringValue];
        NSString *path;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [[paths objectAtIndex:0] stringByAppendingPathComponent:faveDirectory];
        NSString *tempPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:tempDirectory];
        
        NSString *uniqueSmallPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.png",nameString,@"small"]];
        
        NSString *uniqueBigPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.png",nameString,@"big"]];
        
        // Check for file existence of big file and move
        if([[NSFileManager defaultManager] fileExistsAtPath: uniqueSmallPath])
        {
            NSLog(@"Moving Small File...");
            
             NSString *uniqueFaveSmallPath = [tempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.png",nameString,@"small"]];
            
            [[NSFileManager defaultManager] moveItemAtPath:uniqueSmallPath toPath:uniqueFaveSmallPath error:nil];
        }
        
        // Check for file existence of big file and move
        if([[NSFileManager defaultManager] fileExistsAtPath: uniqueBigPath])
        {
            NSLog(@"Moving Big File...");
            
            NSString *uniqueFaveBigPath = [tempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.png",nameString,@"big"]];
            
            [[NSFileManager defaultManager] moveItemAtPath: uniqueBigPath toPath:uniqueFaveBigPath error:nil];
            
        }
    } else {
        NSLog(@"****************************************");
        NSLog(@"NOT Moving Small File...");
        NSLog(@"****************************************");
    }
    
}
-(BOOL)checkIfFavorite:(NSString *)movieId{
    NSEntityDescription *entity;
    @try 
    {
        entity =
        [NSEntityDescription entityForName:@"Movie"
                    inManagedObjectContext:managedObjectContext];
    }
    @catch (NSException *exception) 
    {
        // Print exception information
        NSLog(@"NSException caught" );
        NSLog(@"Name: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);
        return NO;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"id == %@ AND isFavorite == %i", movieId, 1];
    [request setPredicate:predicate];
    
    NSError *requestError = nil;
    NSUInteger numberOfRecords = [managedObjectContext countForFetchRequest:request error:&requestError];
    
    NSLog(@"Number of records in faves %u", numberOfRecords);
    //[movieList setTitle: filmTitle]; 
    
    if (numberOfRecords == 0) {
        return NO;
    }else{
        return YES;
    }

}
- (void)setIdFavorite:(NSString *)movieToSet toValue:(BOOL)value {
	NSLog(@"Set Id Favorite Reached");
    NSEntityDescription *entity;
    @try 
    {
        entity =
        [NSEntityDescription entityForName:@"Movie"
                    inManagedObjectContext:managedObjectContext];
    }
    @catch (NSException *exception) 
    {
        // Print exception information
        NSLog(@"NSException caught" );
        NSLog(@"Name: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);
        return;
    }
    
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"id == %@", movieToSet];
    [request setPredicate:predicate];
    
    NSError *requestError = nil;
    
    NSError *error = nil;
	NSArray *result = [managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"The result is:");
    NSLog(@"%@",result);
    Movie *movieObject = [result objectAtIndex:0];
    NSLog(@"%@",movieObject);
	[movieObject setIsFavorite:[NSNumber numberWithBool:value]];
	
	[managedObjectContext save:&error];
	
	if (error) {
		NSLog(@"[ERROR] COREDATA: Save raised an error - '%@'", [error description]);
		return;
	}
    
	NSLog(@"[SUCCESS] COREDATA: Updated product in database!");
    
    
    // Handle Moving Files
    if(value){        
        NSLog(@"****************************************");
        NSLog(@"MOVING File...");
        NSLog(@"****************************************");
        NSString *nameString = [[movieObject id] stringValue];
        NSString *path;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [[paths objectAtIndex:0] stringByAppendingPathComponent:tempDirectory];
        NSString *tempPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:faveDirectory];
        
        NSString *uniqueSmallPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.png",nameString,@"small"]];
        
        NSString *uniqueBigPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.png",nameString,@"big"]];
        
        // Check for file existence of big file and move
        if([[NSFileManager defaultManager] fileExistsAtPath: uniqueSmallPath])
        {
            NSLog(@"Moving Small File...");
            
            NSString *uniqueFaveSmallPath = [tempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.png",nameString,@"small"]];
            
            [[NSFileManager defaultManager] moveItemAtPath:uniqueSmallPath toPath:uniqueFaveSmallPath error:nil];
        }
        
        // Check for file existence of big file and move
        if([[NSFileManager defaultManager] fileExistsAtPath: uniqueBigPath])
        {
            NSLog(@"Moving Big File...");
            
             NSString *uniqueFaveBigPath = [tempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.png",nameString,@"big"]];
            
            [[NSFileManager defaultManager] moveItemAtPath: uniqueBigPath toPath:uniqueFaveBigPath error:nil];
            
        }
    } else {
        NSLog(@"****************************************");
        NSLog(@"NOT Moving Small File...");
        NSLog(@"****************************************");
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