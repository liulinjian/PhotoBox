//
//  PhotoBoxMasterViewController.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IconDownloader.h"
#import "PhotoBoxCustomCell.h"

@class PhotoDataController;

@interface PhotoBoxListViewController : UITableViewController

@property (nonatomic) NSInteger *currRow;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (strong, nonatomic) PhotoDataController *dataController;

- (void)setTableSource:(NSArray *)photos;
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
- (IBAction)handleFullScreenButton:(UIButton *)sender;
- (IBAction)handleWebViewButton:(UIButton *)sender;

@end
