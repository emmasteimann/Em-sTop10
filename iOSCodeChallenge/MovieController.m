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

@synthesize managedObjectContext, movieArray; 

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
    NSLog(@"Request comlpete. Handling data."); 
    //NSString *jsonData = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData //1
                                                         options:kNilOptions 
                                                           error:&error];
    NSArray* moviesJson = [json objectForKey:@"movies"];
    //    NSDictionary* movies = [NSDictionary dictionaryWithObjectsAndKeys: 
    //                            [json objectForKey:@"movies"], @"movies",
    //                            nil];
    //    NSDictionary* films = [movies objectForKey:@"movies"];
    NSLog(@"%u",[moviesJson count]);
    
    for(int n = 1; n < [moviesJson count]; n = n + 1){
        Movie *movieList = (Movie *)[NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:managedObjectContext];
        
        NSDictionary* film = [moviesJson objectAtIndex:n];
        NSString* filmTitle = [film objectForKey:@"title"];
        NSLog(@"-------------------------------START---------------------------");
        NSLog(@"%@",filmTitle);
        NSLog(@"-------------------------------END---------------------------");
        
        
        [movieList setTitle: filmTitle]; 
        NSError *error;
        
        if(![managedObjectContext save:&error]){
            
            //This is a serious error saying the record
            //could not be saved. Advise the user to
            //try again or restart the application. 
            
        }
        [movieArray addObject:movieList];
        NSLog(@"%@",movieList);
    }
    NSLog(@"%@",movieArray);
    
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