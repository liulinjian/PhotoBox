//
//  ParseSizesOperation.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

typedef void (^ArrayBlock)(NSArray *);
typedef void (^ErrorBlock)(NSError *);

extern NSString *kAddPhotoSizesNotif;
extern NSString *kPhotoSizesResultsKey;

extern NSString *kPhotoSizesErrorNotif;
extern NSString *kPhotoSizesMsgErrorKey;

#import <Foundation/Foundation.h>

@class PhotoSizesObject;

@interface ParseSizesOperation : NSOperation {
    ArrayBlock      completionHandler;
    ErrorBlock      errorHandler;
    
    NSData          *dataToParse;
    NSMutableArray  *workingArray;
    PhotoSizesObject     *workingEntry;
    NSMutableString *workingPropertyString;
    NSArray         *elementsToParse;
    
    BOOL storingCharacterData;
    BOOL didAbortParsing;
    NSUInteger parsedPhotosCounter;
}

@property (nonatomic, copy) ErrorBlock errorHandler;

- (id)initWithData:(NSData *)data completionHandler:(ArrayBlock)handler;

@end