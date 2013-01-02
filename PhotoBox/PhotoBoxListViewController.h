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

@interface PhotoBoxListViewController : UITableViewController <UIScrollViewDelegate, IconDownloaderDelegate> {
    NSArray *entries;
    NSMutableDictionary *imageDownloadsInProgress;
}
@property (nonatomic) NSInteger *currRow;
@property (nonatomic, retain) NSArray *entries;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (strong, nonatomic) PhotoDataController *dataController;


- (void)appImageDidLoad:(NSIndexPath *)indexPath;

- (void)setTableSource:(NSArray *)photos;
- (IBAction)handleFullScreenButton:(UIButton *)sender;
- (IBAction)handleWebViewButton:(UIButton *)sender;

@end
