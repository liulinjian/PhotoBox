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


@interface PhotoBoxMasterViewController ()

- (IBAction)handleGetPhotos:(id)sender;
- (void)complete;

@end

@implementation PhotoBoxMasterViewController

@synthesize dataController;

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
    NSLog(@"MasterVC awakeFromNib");
    [super awakeFromNib];
    if (self.dataController == nil)
    {
      self.dataController = [[PhotoDataController alloc] init];  
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

- (void)complete {
    NSLog(@"MasterVC complete");
    [self done:[UIStoryboardSegue segueWithIdentifier:@"viewPhotoList" source:nil destination:nil performHandler:nil]];
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    NSLog(@"MasterVC done");
    if ([[segue identifier] isEqualToString:@"viewPhotoList"]) {
        
        PhotoBoxListViewController *newController = [segue destinationViewController];
        newController.dataController = self.dataController;
        
    }
}

- (IBAction)handleGetPhotos:(id)sender {
    NSLog(@"handleGetPhotos");
    
    [dataController loadDataList];
}

@end
