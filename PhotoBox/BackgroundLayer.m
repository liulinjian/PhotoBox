//
//  BackgroundLayer.m
//  PhotoBox
//
//  Created by Kristen Novak on 1/1/13.
//  Copyright (c) 2013 Kristen Novak. All rights reserved.
//

#import "BackgroundLayer.h"

@implementation BackgroundLayer

+ (CAGradientLayer*) bgGradient {
    
    UIColor *colorOne = [UIColor colorWithRed:(49/255.0) green:(7/255.0) blue:(101/255.0) alpha:1.0];
    
    UIColor *colorTwo = [UIColor colorWithRed:(0)  green:(0)  blue:(0)  alpha:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    return headerLayer;
}

@end
