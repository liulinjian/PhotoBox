//
//  XMLDownloader.h
//  PhotoBox
//
//  Created by Kristen Novak on 1/2/13.
//  Copyright (c) 2013 Kristen Novak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoObject;
@class PhotoBoxListViewController;

@protocol XMLDownloaderDelegate;

@interface XMLDownloader : NSObject {

    // for downloading image size xml
    NSURLConnection *photoSizesConnection;
    NSOperationQueue *parseQueue;
    NSMutableData *sizesData;
    
    PhotoObject *photoObject;
    NSIndexPath *indexPathInTableView;
    id <XMLDownloaderDelegate> delegate;
}

@property (nonatomic, retain) PhotoObject *photoObject;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, retain) id <XMLDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *sizesData;
@property (nonatomic, retain) NSOperationQueue *parseQueue;
@property (nonatomic, retain) NSURLConnection *photoSizesConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol XMLDownloaderDelegate <NSObject>
- (void)xmlDidLoad:(NSIndexPath *)indexPath;
@end
