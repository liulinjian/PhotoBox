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
#import "ParseSizesOperation.h"

// this framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code
#import <CFNetwork/CFNetwork.h>


@interface PhotoBoxMasterViewController ()

@property (nonatomic, retain) NSURLConnection *photoFeedConnection;
@property (nonatomic, retain) NSOperationQueue *parseQueue;
@property (nonatomic, retain) NSMutableData *photosData;

- (IBAction)handleGetPhotos:(id)sender;

@end

@implementation PhotoBoxMasterViewController

@synthesize photoFeedConnection;
@synthesize parseQueue;
@synthesize photosData;

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = TRUE;
    self.navigationController.toolbarHidden = TRUE;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataController = [[PhotoDataController alloc] init];
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
    NSLog(@"handleGetPhotos");
    [self loadPhotoFeed];
}

-(void)loadPhotoFeed {
    NSLog(@"loadPhotoFeed");
    
    static NSString *feedURLString = @"http://work.dc.akqa.com/recruiting/services/getPhotos.php";
    NSURLRequest *photoURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.photoFeedConnection = [[NSURLConnection alloc] initWithRequest:photoURLRequest delegate:self];
    
    NSAssert(self.photoFeedConnection != nil, @"Failure to create URL connection.");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    parseQueue = [NSOperationQueue new];
    
}

-(void)handleFeedLoadComplete:(NSArray *)photos {
    NSLog(@"handleFeedLoadComplete");
    [self.dataController addPhotosToList:photos];
    [self handleLoadComplete];
}

-(void)handleLoadComplete {
    NSLog(@"handleLoadComplete");
    [self performSegueWithIdentifier:@"viewPhotoList" sender:self];
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
    } 
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == self.photoFeedConnection) {
        [photosData appendData:data];
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
        
    }
}

@end
