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
    NSLog(@"configureView");
    if (self.webview == nil) {
        self.webview = [[UIWebView alloc]init];
        // webview.delegate = self;
    }
    if (self.photo) {
        NSURL *url = [NSURL URLWithString:self.photoURL];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [self.webview loadRequest:req];

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
