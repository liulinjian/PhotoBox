//
//  PhotoBoxDetailViewController.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoObject;

@interface PhotoBoxDetailViewController : UIViewController {
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (strong, nonatomic) IBOutlet UIImageView *photoView;

@property (strong, nonatomic) PhotoObject *photo;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end
