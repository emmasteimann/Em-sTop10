//
//  CustomMovieCell.h
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomMovieCell : UITableViewCell
{
    UILabel *movieName;
    UIImageView *imageView;
    NSString *ratingValue;
    NSString *mpaaRated;
    UIImageView *ratingImage;
    UIProgressView *ratingBar;
}
- (void)setMovieCellName:(NSString *)nameOfMovie andMovieImage:(UIImage *)posterImage andCriticRatingValue:(NSString *)criticRatingValue andMPAA:(NSString *)mpaa;
@end
