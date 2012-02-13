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
        // Initialization code
       //UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
        
       // slider.minimumValue = 0;
       // slider.maximumValue = 100;
        
        //[self.contentView bringSubviewToFront:ratingBar];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
