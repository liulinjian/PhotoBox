//
//  ImageDownloader.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "IconDownloader.h"
#import "PhotoObject.h"
#import "PhotoBoxListViewController.h"

@interface IconDownloader ()

@end

@implementation IconDownloader

@synthesize photoObject;
@synthesize indexPathInTableView;

@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

#pragma mark

- (void)startDownload
{
    if (photoObject.thumbnail)
    {
        [self loadImage];
    }
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

-(void)loadImage {
    self.activeDownload = [NSMutableData data];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:photoObject.thumbnail]] delegate:self];
    self.imageConnection = conn;
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot load data"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    // [alertView release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == self.imageConnection)
    {
        NSLog(@"IconDownloader: didReceiveData");
        [self.activeDownload appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
                                                             forKey: NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    }
    else
    {
        [self handleError:error];
    }
    
    if (connection == self.imageConnection)
    {
        NSLog(@"IconDownloader: didFailWithError");
        self.activeDownload = nil;
        self.imageConnection = nil;
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (connection == self.imageConnection) {
        UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
        
        NSLog(@"IconDownloader: connectionDidFinishLoading, %@, %@", self.indexPathInTableView, image);
        
        self.photoObject.thumbImage = image;
        self.activeDownload = nil;
        // [image release];
        self.imageConnection = nil;
        
        [delegate appImageDidLoad:self.indexPathInTableView];
    }
}


@end