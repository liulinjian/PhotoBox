//
//  PhotoBoxCustomCell.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "PhotoBoxCustomCell.h"

@implementation PhotoBoxCustomCell

@synthesize background;
@synthesize imageView;
@synthesize titleLabel;
@synthesize userLabel;
@synthesize fullscreenButton;
@synthesize webviewButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        // TODO
        // ADD FRAME
        
        [self.titleLabel setText:@"Title"];
        [self.userLabel setText:@"User"];
        
    }
    
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
