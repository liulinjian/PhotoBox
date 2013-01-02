//
//  PhotoBoxMasterViewController.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IconDownloader.h"
#import "XMLDownloader.h"
#import "PhotoBoxCustomCell.h"

@class PhotoDataController;

@interface PhotoBoxListViewController : UITableViewController <UIScrollViewDelegate, IconDownloaderDelegate, XMLDownloaderDelegate> {
    
    NSMutableDictionary *imageDownloadsInProgress;
    NSMutableDictionary *xmlDownloadsInProgress;
}

@property (nonatomic) NSInteger *currRow;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSMutableDictionary *xmlDownloadsInProgress;
@property (strong, nonatomic) PhotoDataController *dataController;


- (void)appImageDidLoad:(NSIndexPath *)indexPath;
- (void)xmlDidLoad:(NSIndexPath *)indexPath;

- (void)setTableSource:(NSArray *)photos;
- (IBAction)handleFullScreenButton:(UIButton *)sender;
- (IBAction)handleWebViewButton:(UIButton *)sender;

@end
