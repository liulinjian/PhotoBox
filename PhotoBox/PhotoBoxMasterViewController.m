//
//  PhotoBoxMasterViewController.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "PhotoBoxMasterViewController.h"
#import "PhotoBoxListViewController.h"

#import "PhotoDataController.h"
#import "PhotoObject.h"

#import "ParseFeedOperation.h"

// this framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code
#import <CFNetwork/CFNetwork.h>


@interface PhotoBoxMasterViewController ()

@property (nonatomic, retain) NSURLConnection *photoFeedConnection;
@property (nonatomic, retain) NSURLConnection *photoSizesConnection;
@property (nonatomic, retain) NSOperationQueue *parseQueue;
@property (nonatomic, retain) NSMutableData *photosData;
@property (nonatomic, retain) NSMutableData *sizesData;
@property (nonatomic, retain) PhotoObject *currPhoto;

- (IBAction)handleGetPhotos:(id)sender;
- (void)handleLoadComplete;
- (void)loadImageSizes:(NSUInteger *)photoIndex;

@end

@implementation PhotoBoxMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataController = [[PhotoDataController alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dataController = [[PhotoDataController alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"MasterVC prepareForSegue");
    if ([[segue identifier] isEqualToString:@"viewPhotoList"]) {
        
        PhotoBoxListViewController *newController = [segue destinationViewController];
        newController.dataController = self.dataController;
        
    }
}

- (IBAction)handleGetPhotos:(id)sender {
    [self loadPhotoFeed];
}

-(void)loadPhotoFeed {
    
    static NSString *feedURLString = @"http://work.dc.akqa.com/recruiting/services/getPhotos.php";
    NSURLRequest *photoURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.photoFeedConnection = [[NSURLConnection alloc] initWithRequest:photoURLRequest delegate:self];
    
    NSAssert(self.photoFeedConnection != nil, @"Failure to create URL connection.");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    parseQueue = [NSOperationQueue new];
    
}

-(void)handleFeedLoadComplete:(NSArray *)photos {
    [self.dataController addPhotosToList:photos];
    [self loadImageSizes:0];
}

-(void)loadImageSizes:(NSUInteger *)photoIndex {
    NSLog(@"MasterVC handleLoadComplete");
    self.currPhoto = [self.dataController getPhotoAtIndex:*photoIndex];
    
    // parse getSizes URL
    static NSString *getSizesURL = @"http://work.dc.akqa.com/recruiting/services/getSizes.php?id=<photoID>";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\<photoID>" options:NSRegularExpressionCaseInsensitive error:&error];
    getSizesURL = [regex stringByReplacingMatchesInString:getSizesURL options:0 range:NSMakeRange(0, [getSizesURL length]) withTemplate:self.currPhoto.photoID];
    
    // set up request and connection for getSizes request
    NSURLRequest *photoSizesURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:getSizesURL]];
    self.photoSizesConnection = [[NSURLConnection alloc] initWithRequest:photoSizesURLRequest delegate:self];
    
    NSAssert(self.photoSizesConnection != nil, @"Failure to create URL connection.");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    parseQueue = [NSOperationQueue new];
    
//    [self performSegueWithIdentifier:@"viewPhotoList" sender:self];
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
    if (connection == self.photoFeedConnection) {
        self.photosData = [NSMutableData data];
    } else if (connection == self.photoSizesConnection) {
        self.sizesData = [NSMutableData data];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == self.photoFeedConnection) {
        [photosData appendData:data];
    } else if (connection == self.photoSizesConnection) {
        [sizesData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
															 forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [self handleError:noConnectionError];
    }
	else
	{
        [self handleError:error];
    }
    
    if (connection == self.photoFeedConnection) {
        self.photoFeedConnection = nil;
    } else if (connection == self.photoSizesConnection) {
        self.photoSizesConnection = nil;
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.parseQueue = [[NSOperationQueue alloc] init];// autorelease];
    
    if (connection == self.photoFeedConnection) {
        self.photoFeedConnection = nil;
        ParseFeedOperation *parser = [[ParseFeedOperation alloc] initWithData:photosData
                                                            completionHandler:^(NSArray *photoList) {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    
                                                                    [self handleFeedLoadComplete:photoList];
                                                                    
                                                                });
                                                                
                                                                self.parseQueue = nil;
                                                            }];
        
        parser.errorHandler = ^(NSError *parseError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self handleError:parseError];
                
            });
        };
        
        [parseQueue addOperation:parser];
        // [parser release];
        self.photosData = nil;
        
    } else if (connection == self.photoSizesConnection) {
        self.photoSizesConnection = nil;
        ParseFeedOperation *parser = [[ParseFeedOperation alloc] initWithData:photosData
                                                            completionHandler:^(NSArray *photoList) {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    
                                                                    [self handleFeedLoadComplete:photoList];
                                                                    
                                                                });
                                                                
                                                                self.parseQueue = nil;
                                                            }];
        
        parser.errorHandler = ^(NSError *parseError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self handleError:parseError];
                
            });
        };
        
        [parseQueue addOperation:parser];
        // [parser release];
        self.photosData = nil;
    }
    
    
    
    
    
    
}

@end
