//
//  XMLDownloader.m
//  PhotoBox
//
//  Created by Kristen Novak on 1/2/13.
//  Copyright (c) 2013 Kristen Novak. All rights reserved.
//

#import "XMLDownloader.h"

#import "PhotoObject.h"
#import "PhotoSizesObject.h"
#import "PhotoBoxListViewController.h"

#import "ParseSizesOperation.h"

@implementation XMLDownloader

@synthesize photoObject;
@synthesize indexPathInTableView;

@synthesize photoSizesConnection;
@synthesize parseQueue;
@synthesize sizesData;

- (void)startDownload
{
    NSLog(@"XML: startDownload: %@", photoObject.photoID);
    if (!photoObject.thumbnail)
    {
        [self loadSizes];
    } else {
        [delegate xmlDidLoad:self.indexPathInTableView];
    }
}

- (void)cancelDownload
{
    [self.photoSizesConnection cancel];
    self.photoSizesConnection = nil;
    self.sizesData = nil;
}

-(void)loadSizes{
    if (photoObject.thumbnail)
    {
        [delegate xmlDidLoad:self.indexPathInTableView];
        return;
    }
    static NSString *getSizesURL = @"http://work.dc.akqa.com/recruiting/services/getSizes.php?id=<photoID>";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\<photoID>" options:NSRegularExpressionCaseInsensitive error:&error];
    getSizesURL = [regex stringByReplacingMatchesInString:getSizesURL options:0 range:NSMakeRange(0, [getSizesURL length]) withTemplate:photoObject.photoID];
    
    NSLog(@"LoadSizes: %@", getSizesURL);
    // set up request and connection for getSizes request
    NSURLRequest *photoSizesURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:getSizesURL]];
    self.photoSizesConnection = [[NSURLConnection alloc] initWithRequest:photoSizesURLRequest delegate:self];
    
    NSAssert(self.photoSizesConnection != nil, @"Failure to create URL connection.");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    parseQueue = [NSOperationQueue new];
}

-(void)handleSizesLoadComplete:(NSArray *)sizesArr
{
    NSLog(@"handleSizesLoadComplete");
    PhotoSizesObject *sizeObj = [sizesArr objectAtIndex:0];
    NSLog(sizeObj.thumbnail);
    photoObject.thumbnail = sizeObj.thumbnail;
    photoObject.small = sizeObj.small;
    photoObject.medium = sizeObj.medium;
    photoObject.original = sizeObj.original;
    
}

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
    if (connection == self.photoSizesConnection)
    {
        self.sizesData = [NSMutableData data];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == self.photoSizesConnection)
    {
        [sizesData appendData:data];
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
    
    if (connection == self.photoSizesConnection)
    {
        self.photoSizesConnection = nil;
    } 
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (connection == self.photoSizesConnection) {
        self.parseQueue = [[NSOperationQueue alloc] init];// autorelease];
        
        self.photoSizesConnection = nil;
        ParseSizesOperation *parser2 = [[ParseSizesOperation alloc] initWithData: sizesData     completionHandler:^(NSArray *sizesArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleSizesLoadComplete:sizesArray];
            });
            self.parseQueue = nil;
        }];
        
        parser2.errorHandler = ^(NSError *parseError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleError:parseError];
            });
        };
        
        [parseQueue addOperation:parser2];
        // [parser2 release];
        self.sizesData = nil;
        
        [delegate xmlDidLoad:self.indexPathInTableView];
    }
}


@end
