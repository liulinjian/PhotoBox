//
//  ParseOperation.h
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

extern NSString *kAddPhotosNotif;
extern NSString *kPhotoResultsKey;

extern NSString *kPhotosErrorNotif;
extern NSString *kPhotosMsgErrorKey;

@class PhotoObject;

@interface ParseOperation : NSOperation {
    NSData *photoData;
    
@private
    // these variables are used during parsing
    PhotoObject *currentPhotoObject;
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;
    
    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
    NSUInteger parsedPhotosCounter;
}

@property (copy, readonly) NSData *photoData;

- (id)initWithData:(NSData *)parseData;

@end