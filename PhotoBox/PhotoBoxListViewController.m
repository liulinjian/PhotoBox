//
//  PhotoBoxMasterViewController.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "PhotoBoxListViewController.h"
#import "PhotoBoxDetailViewController.h"
#import "PhotoBoxWebViewController.h"

#import "PhotoDataController.h"
#import "PhotoObject.h"
#import "BackgroundLayer.h"

@interface PhotoBoxListViewController ()

- (IBAction)handleFullScreenButton:(UIButton *)sender;
- (IBAction)handleWebViewButton:(UIButton *)sender;

-(void)setTableSource:(NSArray *)photos;
- (NSString *) photoURL:(NSString *)photoID userID:(NSString *)userID;
- (void)startIconDownload:(PhotoObject *)photoObject forIndexPath:(NSIndexPath *)indexPath;

@end


@implementation PhotoBoxListViewController

@synthesize entries;
@synthesize imageDownloadsInProgress;

-(void)viewWillAppear:(BOOL)animated{
    CAGradientLayer *bgLayer = [BackgroundLayer bgGradient];
    bgLayer.frame = self.tableView.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

- (IBAction)handleFullScreenButton:(UIButton *)sender {
    self.currRow = (NSInteger *)sender.tag;
}

- (IBAction)handleWebViewButton:(UIButton *)sender {
    self.currRow = (NSInteger *)sender.tag;
}

- (void)setTableSource:(NSArray *)photos {
    //NSLog(@"%d",self.dataController.numberPhotos);
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataController numberPhotos];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    
    PhotoBoxCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSLog(@"Cell created!");
        // cell = [[PhotoBoxCustomCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier]; //autorelease
        
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PhotoBoxCustomCell" owner:nil options:nil];
        
        for(id currentObject in nibObjects)
        {
            if ([currentObject isKindOfClass:[PhotoBoxCustomCell class]])
            {
                cell = (PhotoBoxCustomCell *)currentObject;
            }
        }
        
    }
    
    NSLog(@"cell creation: %d",indexPath.row);
    PhotoObject *currPhoto = [self.dataController getPhotoAtIndex:indexPath.row];
    [[cell titleLabel] setText:currPhoto.title];
    [[cell userLabel] setText:currPhoto.user];
    [[cell imageView] setImage:[UIImage imageNamed:@"placeholder_t.jpg"]];
    [[cell fullscreenButton] setTag:indexPath.row];
    [[cell webviewButton] setTag:indexPath.row];
    
    // Only load cached images; defer new downloads until scrolling ends
    if (!currPhoto.thumbImage)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startIconDownload:currPhoto forIndexPath:indexPath];
        }
    } else
    {
        cell.imageView.image = currPhoto.thumbImage;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSUInteger rowForAccess= (NSUInteger)self.currRow;
    PhotoObject *tempPhoto = [self.dataController getPhotoAtIndex:(NSUInteger)rowForAccess];
    // NSLog(@"ListVC prepareForSeque, %@",tempPhoto.photoID);
    
    if ([[segue identifier] isEqualToString:@"openFullScreen"]) {
        PhotoBoxDetailViewController *detailVC = [segue destinationViewController];
        detailVC.photo = tempPhoto;
        
    } else if ([[segue identifier] isEqualToString:@"openWebView"]) {
        PhotoBoxWebViewController *webviewVC = [segue destinationViewController];
        webviewVC.photo = tempPhoto;
        
    }
}



#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(PhotoObject *)photo forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        NSLog(@"ListView: startIconDownload with NEW iconDownloader");
        NSLog(@"ListView: startIconDownload: %@, %@", indexPath, photo.thumbnail);
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.photoObject = photo;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        // [iconDownloader release];
    } 
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    NSLog(@"ListView: loadImagesForOnscreenRows");
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        PhotoObject *photo = [self.dataController getPhotoAtIndex:indexPath.row];
        if (!photo.thumbImage)
        {
            [self startIconDownload:photo forIndexPath:indexPath];
        }
    }
    
}

- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        NSLog(@"ListView: appImageDidLoad: %@", indexPath);
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        cell.imageView.image = iconDownloader.photoObject.thumbImage;
    }
    [imageDownloadsInProgress removeObjectForKey:indexPath];

}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


@end
