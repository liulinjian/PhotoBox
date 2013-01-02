//
//  ImageDownloader.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoObject;
@class PhotoBoxListViewController;

@protocol IconDownloaderDelegate;

@interface IconDownloader : NSObject {
    
    PhotoObject *photoObject;
    NSIndexPath *indexPathInTableView;
    id <IconDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) PhotoObject *photoObject;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, retain) id <IconDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol IconDownloaderDelegate <NSObject>
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
@end
