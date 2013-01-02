//
//  PhotoBoxWebViewController.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "PhotoBoxWebViewController.h"
#import "PhotoObject.h"

@interface PhotoBoxWebViewController ()
- (void)configureView;
- (NSString *) photoURL;
@end

@implementation PhotoBoxWebViewController

- (void)setPhoto:(PhotoObject *)newPhoto
{
    NSLog(@"WebVC setPhoto");
    if (_photo != newPhoto) {
        _photo = newPhoto;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    if (self.webview == nil) {
        NSLog(@"configureView");
        self.webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
        self.webview.delegate = self;    // weak reference: doesn't retain self
        self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.webview.scalesPageToFit = YES;
        self.webview.autoresizesSubviews = YES;
        self.view = self.webview;        // strong reference: retains webView
        
    }
    if (self.photo) {
        NSLog(@"%@", self.photo);
        
        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.photoURL]]]; //self.photoURL
    }
}

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = FALSE;
    self.navigationController.toolbarHidden = TRUE;
    self.navigationItem.hidesBackButton = NO;
	// Do any additional setup after loading the view.
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.photoURL]]];
}

- (void)viewWillAppear:(BOOL)animated
{
	self.webview.delegate = self;	// setup the delegate as the web view is shown
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.webview stopLoading];	// in case the web view is still loading its content
	self.webview.delegate = nil;	// disconnect the delegate as the webview is hidden
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
    // starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webView:didFailLoadWithError");
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	// report the error inside the webview
	NSString* errorString = [NSString stringWithFormat:
							 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
							 error.localizedDescription];
	[self.webview loadHTMLString:errorString baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
