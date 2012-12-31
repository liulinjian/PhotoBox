//
//  PhotoBoxMasterViewController.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoDataController;

@interface PhotoBoxMasterViewController : UIViewController

@property (strong, nonatomic) PhotoDataController *dataController;

- (IBAction)handleGetPhotos:(id)sender;
- (void)complete;

@end
