//
//  PhotoBoxMasterViewController.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoBoxCustomCell.h"

@class PhotoDataController;

@interface PhotoBoxListViewController : UITableViewController

@property (strong, nonatomic) PhotoDataController *dataController;

- (void)setTableSource:(NSArray *)photos;

@end
