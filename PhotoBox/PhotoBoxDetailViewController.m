//
//  PhotoBoxDetailViewController.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "PhotoBoxDetailViewController.h"
#import "PhotoObject.h"

@interface PhotoBoxDetailViewController ()
- (void)configureView;
- (NSString *) photoURL;
@end

@implementation PhotoBoxDetailViewController

@synthesize activeDownload;
@synthesize imageConnection;
@synthesize photoView;

#pragma mark - Managing the detail item

- (void)setPhoto:(PhotoObject *)newPhoto
{
    NSLog(@"DetailCV setPhotoURL %@",newPhoto);
    if (_photo != newPhoto) {
        _photo = newPhoto;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    NSLog(@"DetailVC configureView, %@", self.photo);
    if (self.photo) {
        // TODO: Config Photo Loading
        [self startDownload];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:self.photoURL]] delegate:self];
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
    NSLog(@"connection didReceiveData");
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"connection didFailWithError");
    self.activeDownload = nil;
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connection didFinishLoading");
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    self.photoView.image = image;
    
    self.activeDownload = nil;
    // [image release];
    self.imageConnection = nil;
}

- (NSString *) photoURL {
    
    NSError *error = NULL;
    NSString *tempPhotoURL = @"http://work.dc.akqa.com/recruiting/photos/<userID>/<photoID>.jpg";
    
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"\\<userID>" options:NSRegularExpressionCaseInsensitive error:&error];
    tempPhotoURL = [regex1 stringByReplacingMatchesInString:tempPhotoURL options:0 range:NSMakeRange(0, [tempPhotoURL length]) withTemplate:self.photo.userID];
    
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"\\<photoID>" options:NSRegularExpressionCaseInsensitive error:&error];
    tempPhotoURL = [regex2 stringByReplacingMatchesInString:tempPhotoURL options:0 range:NSMakeRange(0, [tempPhotoURL length]) withTemplate:self.photo.photoID];
    
    return tempPhotoURL;
}

@end
