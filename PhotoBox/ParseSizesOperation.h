//
//  ParseSizesOperation.h
//  PhotoBox
//
//  Created by Kristen Novak on 1/1/13.
//  Copyright (c) 2013 Kristen Novak. All rights reserved.
//

typedef void (^ArrayBlock)(NSArray *);
typedef void (^ErrorBlock)(NSError *);

extern NSString *kAddPhotosNotif;
extern NSString *kPhotoResultsKey;

extern NSString *kPhotosErrorNotif;
extern NSString *kPhotosMsgErrorKey;

#import <Foundation/Foundation.h>

@class PhotoSizesObject;

@interface ParseSizesOperation : NSObject{
    ArrayBlock      completionHandler;
    ErrorBlock      errorHandler;
    
    NSData          *dataToParse;
    NSMutableArray  *workingArray;
    PhotoSizesObject *workingEntry;
    NSMutableString *workingPropertyString;
    NSArray         *elementsToParse;
    
    BOOL storingCharacterData;
    BOOL didAbortParsing;
    NSUInteger parsedSizesCounter;
}

@property (nonatomic, copy) ErrorBlock errorHandler;

- (id)initWithData:(NSData *)data completionHandler:(ArrayBlock)handler;

@end