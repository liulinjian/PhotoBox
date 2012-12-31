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
@end

@implementation PhotoBoxDetailViewController

#pragma mark - Managing the detail item

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
        // TODO: Config Photo Loading
        // self.photoView.image = thePhoto.thumb;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
