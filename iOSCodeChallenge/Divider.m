//
//  Divider.m
//  iOSCodeChallenge
//
//  Created by Emma Steimann on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Divider.h"

@implementation Divider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
#pragma mark - Draw rectangle fitting view
- (void) drawRect: (CGRect) rect
{
    UIColor *currentColor = [UIColor blackColor];
    
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, currentColor.CGColor);
    CGContextMoveToPoint(context, self.bounds.origin.x, self.bounds.origin.y);
    CGContextAddLineToPoint(context, self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y + self.bounds.size.height);
    CGContextStrokePath(context);
}

@end
