//
//  PhotoBoxWebViewController.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/30/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoObject;

@interface PhotoBoxWebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) PhotoObject *photo;
@property (nonatomic, retain) IBOutlet UIWebView *webview;

@end
