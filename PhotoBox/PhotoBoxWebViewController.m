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
@end

@implementation PhotoBoxWebViewController

- (void)setPhotoObject:(id)newPhoto
{
    if (_photo != newPhoto) {
        _photo = newPhoto;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    PhotoObject *thePhoto = self.photo;
    
    if (thePhoto) {
        // TODO: Config Web View
        // self.webview
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

@end
