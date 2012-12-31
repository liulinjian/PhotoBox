//
//  PhotoDataController.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "PhotoBoxMasterViewController.h"
#import "PhotoBoxListViewController.h"

#import "PhotoDataController.h"
#import "PhotoObject.h"
#import "ParseOperation.h"

// this framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code
#import <CFNetwork/CFNetwork.h>

@interface PhotoDataController ()

@property (nonatomic, copy) PhotoBoxMasterViewController *masterView;
@property (nonatomic, copy) PhotoBoxListViewController *listView;
@property (nonatomic, retain) NSURLConnection *photoFeedConnection;
@property (nonatomic, retain) NSMutableData *photoData;    // the data returned from the NSURLConnection
@property (nonatomic, retain) NSOperationQueue *parseQueue;     // the queue that manages our NSOperation for parsing photo data

-(void)initializeDefaultList;
-(void)loadDataList;
- (void)addPhotosToList:(NSArray *)photos;
- (void)handleError:(NSError *)error;

@end

@implementation PhotoDataController

@synthesize masterView;
@synthesize listView;
@synthesize photoFeedConnection;
@synthesize photoData;
@synthesize parseQueue;

/**
- (void)dealloc {
    [photoFeedConnection cancel];
    // [photoFeedConnection release];
    
    // [photoData release];
    
    // [parseQueue release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPhotosNotif object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPhotosErrorNotif object:nil];
    
    [super dealloc];
}
**/

-(void)initializeDefaultList {
    NSMutableArray *newPhotoList = [[NSMutableArray alloc] init];
    self.masterPhotoList = newPhotoList;
    
    /**
    PhotoObject *newPhoto;
    newPhoto = [[PhotoObject alloc] initWithID:@"id" userID:@"userID" title:@"title" user:@"user"];
    [self AddPhotoToList:newPhoto];
    **/
}

-(void)loadDataList {
    // Use NSURLConnection to asynchronously download
    static NSString *feedURLString = @"http://work.dc.akqa.com/recruiting/services/getPhotos.php";
    NSURLRequest *photoURLRequest =
    [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.photoFeedConnection = [[NSURLConnection alloc] initWithRequest:photoURLRequest delegate:self];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development.
    // If the URL is more dynamic, then you should implement a more flexible validation technique,
    // and be able to both recover from errors and communicate problems to the user in an
    // unobtrusive manner.
    NSAssert(self.photoFeedConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection
    // finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    parseQueue = [NSOperationQueue new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addPhotos:)
                                                 name:kAddPhotosNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(photosError:)
                                                 name:kPhotosErrorNotif
                                               object:nil];
}

- (void)setMasterPhotoList:(NSMutableArray *)newPhotoList {
    if (_masterPhotoList != newPhotoList) {
        _masterPhotoList = [newPhotoList mutableCopy];
    }
}

- (id)init {
    if (self = [super init]) {
        [self initializeDefaultList];
        return self;
    }
    return nil;
}

-(NSUInteger)numberPhotos {
    return [self.masterPhotoList count];
}

-(PhotoObject *)getPhotoAtIndex:(NSUInteger)theIndex {
    return [self.masterPhotoList objectAtIndex:theIndex];
}

-(void)AddPhotoToList:(PhotoObject *)newPhotoObj {
    NSLog(@"AddPhotoToList: %@",newPhotoObj.photoID);
    [self.masterPhotoList addObject:newPhotoObj];
}


#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/xml"]) {
        self.photoData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [photoData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:
         NSLocalizedString(@"No Connection Error",
                           @"Error message displayed when not connected to the Internet.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.photoFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.photoFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    ParseOperation *parseOperation = [[ParseOperation alloc] initWithData:self.photoData];
    [self.parseQueue addOperation:parseOperation];
    // [parseOperation release];   
    
    self.photoData = nil;

}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error Title",
                       @"Title for alert displayed when download or parse error occurs.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
    //[alertView release];
}

- (void)addPhotos:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self addPhotosToList:[[notif userInfo] valueForKey:kPhotoResultsKey]];
}

- (void)photosError:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kPhotosMsgErrorKey]];
}

- (void)addPhotosToList:(NSArray *)photos {
    for (PhotoObject *po in photos) {
        [self AddPhotoToList:po];
    }
    [self.listView setTableSource:photos];
}

@end
