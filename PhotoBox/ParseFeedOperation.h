//
//  ParseFeedOperation.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

typedef void (^ArrayBlock)(NSArray *);
typedef void (^ErrorBlock)(NSError *);

extern NSString *kAddPhotosNotif;
extern NSString *kPhotoResultsKey;

extern NSString *kPhotosErrorNotif;
extern NSString *kPhotosMsgErrorKey;

#import <Foundation/Foundation.h>

@class PhotoObject;

@interface ParseFeedOperation : NSOperation {
    ArrayBlock      completionHandler;
    ErrorBlock      errorHandler;
    
    NSData          *dataToParse;
    NSMutableArray  *workingArray;
    PhotoObject     *workingEntry;
    NSMutableString *workingPropertyString;
    NSArray         *elementsToParse;
    
    BOOL storingCharacterData;
    BOOL didAbortParsing;
    NSUInteger parsedPhotosCounter;
}

@property (nonatomic, copy) ErrorBlock errorHandler;

- (id)initWithData:(NSData *)data completionHandler:(ArrayBlock)handler;

@end