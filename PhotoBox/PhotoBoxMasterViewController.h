//
//  PhotoBoxMasterViewController.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoDataController;
@class PhotoObject;

@interface PhotoBoxMasterViewController : UIViewController {
    NSURLConnection *photoFeedConnection;
    NSOperationQueue *parseQueue;
    NSMutableData *photosData;
}

@property (strong, nonatomic) PhotoDataController *dataController;

- (IBAction)handleGetPhotos:(id)sender;

@end
