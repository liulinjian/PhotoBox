//
//  PhotoBoxCustomCell.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBoxCustomCell : UITableViewCell{
    
    IBOutlet UIView *background;
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *userLabel;
    IBOutlet UIButton *fullscreenButton;
    IBOutlet UIButton *webviewButton;
    
}

@property (nonatomic, retain) IBOutlet UIView *background;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *userLabel;
@property (nonatomic, retain) IBOutlet UIButton *fullscreenButton;
@property (nonatomic, retain) IBOutlet UIButton *webviewButton;

@end
