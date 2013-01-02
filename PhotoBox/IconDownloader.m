//
//  ImageDownloader.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "IconDownloader.h"
#import "PhotoObject.h"
#import "PhotoSizesObject.h"
#import "PhotoBoxListViewController.h"

@implementation IconDownloader

@synthesize photoObject;
@synthesize indexPathInTableView;
@synthesize activeDownload;
@synthesize imageConnection;

#pragma mark

/**
- (void)dealloc
{
    [photoObject release];
    [indexPathInTableView release];
    
    [activeDownload release];
    
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}
**/

- (void)startDownload
{
    NSLog(@"IconDownloader: startDownload, %@", photoObject.photoID);
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:photoObject.thumbnail]] delegate:self];
    self.imageConnection = conn;
    // [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"IconDownloader: didReceiveData");
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"IconDownloader: didFailWithError");
    self.activeDownload = nil;
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    NSLog(@"IconDownloader: connectionDidFinishLoading, %@, %@", self.indexPathInTableView, image);
    
    self.photoObject.thumbImage = image;
    self.activeDownload = nil;
    // [image release];
    self.imageConnection = nil;
    
    [delegate appImageDidLoad:self.indexPathInTableView];
}

@end
