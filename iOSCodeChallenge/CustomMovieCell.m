//
//  CustomMovieCell.m
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomMovieCell.h"

@implementation CustomMovieCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        movieName = [[UILabel alloc] initWithFrame:CGRectZero];
        movieName.backgroundColor = [UIColor clearColor];
        [[self contentView] addSubview:movieName];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [[self contentView] addSubview:imageView];
        
        [imageView setContentMode:UIViewContentModeCenter];
        ratingImage = [[UIImageView alloc] init];
        
        [[self contentView] addSubview:ratingImage];
        ratingBar = [[UIProgressView alloc] initWithFrame:CGRectZero];
        [[self contentView] addSubview:ratingBar];
        // Initialization code
       //UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
        
       // slider.minimumValue = 0;
       // slider.maximumValue = 100;
        
        //[self.contentView bringSubviewToFront:ratingBar];
    }
    return self;
}
#pragma mark - layoutSubviews after content loaded
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float inset = 5.0;
    
    CGRect bounds = [[self contentView] bounds];
    
    float h = bounds.size.height;
    float w = bounds.size.width;
    float valueWidth = 180.0;
    
    CGRect imageFrame = CGRectMake(inset, inset, imageView.image.size.width, imageView.image.size.height);
    
    
    CGSize textSize = [[movieName text] sizeWithFont:[movieName font] forWidth:valueWidth lineBreakMode:UILineBreakModeTailTruncation];
    
    CGFloat strikeWidth = textSize.width;
    
    [imageView setFrame:imageFrame];
    
    CGRect nameFrame = CGRectMake(imageFrame.size.width + imageFrame.origin.x + inset, inset, valueWidth, h - inset * 2.0);
    
    [movieName setFrame:nameFrame];
    
    // Handle MPAA icon
    // Would normally use an enum and a switch but 
    // PG-13/NC-17 contain silly little dashes...
    if ([mpaaRated isEqualToString:@"G"]){
        ratingImage.image = [UIImage imageNamed:@"g.png"];
    } else if([mpaaRated isEqualToString:@"PG"]){
        ratingImage.image = [UIImage imageNamed:@"pg.png"];
    } else if([mpaaRated isEqualToString:@"PG-13"]){
        ratingImage.image = [UIImage imageNamed:@"pg_13.png"];
    } else if([mpaaRated isEqualToString:@"R"]){
        ratingImage.image = [UIImage imageNamed:@"r.png"];
    } else if([mpaaRated isEqualToString:@"NC-17"]){
        ratingImage.image = [UIImage imageNamed:@"nc_17.png"];
    } else {
        
    }
    
    UIFont *myFont = [UIFont boldSystemFontOfSize:24.0];
    movieName.font = myFont;
    movieName.minimumFontSize = 14.0;
    //movieName.lineBreakMode = UILineBreakModeWordWrap;
    //movieName.numberOfLines = 0;
    
    float addWidth;
    if (strikeWidth > valueWidth) {
        addWidth = valueWidth;
    }else{
        addWidth = strikeWidth + 6.954; // 5pts ≈ 6.954px
    }
    [ratingImage setFrame:CGRectMake(movieName.frame.origin.x+addWidth,  h/2 - (ratingImage.image.size.height /2), ratingImage.image.size.width, ratingImage.image.size.height)];
    
    // Add rating bar 
    [ratingBar setFrame:CGRectMake(75, textSize.height+55, 150, 30)];
    float progess = [ratingValue floatValue];
    [ratingBar setProgress:(progess/ 100)];
}
#pragma mark - Set Cell information
- (void)setMovieCellName:(NSString *)nameOfMovie andMovieImage:(UIImage *)posterImage andCriticRatingValue:(NSString *)criticRatingValue andMPAA:(NSString *)mpaa
{
    [movieName setText:nameOfMovie];
    imageView.image = posterImage;
    ratingValue = criticRatingValue;
    mpaaRated = mpaa;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
