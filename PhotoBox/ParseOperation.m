//
//  ParseOperation.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "ParseOperation.h"
#import "PhotoObject.h"

// NSNotification name for sending photo data back to the app delegate
NSString *kAddPhotosNotif = @"AddPhotosNotif";

// NSNotification userInfo key for obtaining the photo data
NSString *kPhotoResultsKey = @"PhotoResultsKey";

// NSNotification name for reporting errors
NSString *kPhotosErrorNotif = @"PhotoErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kPhotosMsgErrorKey = @"PhotosMsgErrorKey";


@interface ParseOperation () <NSXMLParserDelegate>

@property (nonatomic, retain) PhotoObject *currentPhotoObject;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;

- (id)initWithData:(NSData *)parseData;

@end

@implementation ParseOperation

@synthesize photoData, currentPhotoObject, currentParsedCharacterData, currentParseBatch;

- (id)initWithData:(NSData *)parseData
{
    if (self = [super init]) {
        photoData = [parseData copy];
    }
    return self;
}

- (void)addPhotosToList:(NSArray *)photos {
    assert([NSThread isMainThread]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddPhotosNotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:photos
                                                                                           forKey:kPhotoResultsKey]];
}

// the main function for this NSOperation, to start the parsing
- (void)main {
    NSLog(@"Parse Operation: main");
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.photoData];
    [parser setDelegate:self];
    [parser parse];
    
    if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(addPhotosToList:)
                               withObject:self.currentParseBatch
                            waitUntilDone:NO];
    }
    
    self.currentParseBatch = nil;
    self.currentPhotoObject = nil;
    self.currentParsedCharacterData = nil;
    
    // [parser release];
}

/**
- (void)dealloc {
    [photoData release];
    
    [currentPhotoObject release];
    [currentParsedCharacterData release];
    [currentParseBatch release];
    [dateFormatter release];
    
    [super dealloc];
}
**/

#pragma mark -
#pragma mark Parser constants

static const const NSUInteger kMaximumNumberOfPhotosToParse = 50;

static NSUInteger const kSizeOfPhotoBatch = 10;

static NSString * const kPhotoElementName = @"photo";
static NSString * const kPhotoIDAttributeName = @"id";
static NSString * const kUserIDAttributeName = @"user_id";
static NSString * const kTitleAttributeName = @"title";
static NSString * const kUserAttributeName = @"user";

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    // Limit # Photos to Parse
    if (parsedPhotosCounter >= kMaximumNumberOfPhotosToParse) {
        // flag didAbortParsing
        didAbortParsing = YES;
        [parser abortParsing];
    }
    if ([elementName isEqualToString:kPhotoElementName]) {
        PhotoObject *photo = [[PhotoObject alloc] init];
        self.currentPhotoObject = photo;
        NSLog(@"start currentPhotoObject");
        
        NSString *photoIDAttribute = [attributeDict valueForKey:kPhotoIDAttributeName];
        self.currentPhotoObject.photoID = photoIDAttribute;
        NSLog(photoIDAttribute);
        
        NSString *userIDAttribute = [attributeDict valueForKey:kUserIDAttributeName];
        self.currentPhotoObject.userID = userIDAttribute;
        
        NSString *titleAttribute = [attributeDict valueForKey:kTitleAttributeName];
        self.currentPhotoObject.title = titleAttribute;
        
        NSString *userAttribute = [attributeDict valueForKey:kUserAttributeName];
        self.currentPhotoObject.user = userAttribute;
        
        // [photo release];
    }    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:kPhotoElementName]) {
        [self.currentParseBatch addObject:self.currentPhotoObject];
        parsedPhotosCounter++;
        
        NSLog(@"end currentPhotoObject");
        NSLog(@"%d",parsedPhotosCounter);
        
        if ([self.currentParseBatch count] >= kMaximumNumberOfPhotosToParse) {
            [self performSelectorOnMainThread:@selector(addPhotosToList:)
                                   withObject:self.currentParseBatch
                                waitUntilDone:NO];
            self.currentParseBatch = [NSMutableArray array];
        }
    } 
    accumulatingParsedCharacterData = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingParsedCharacterData) {
        [self.currentParsedCharacterData appendString:string];
    }
}

- (void)handlePhotosError:(NSError *)parseError {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPhotosErrorNotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:parseError
                                                                                           forKey:kPhotosMsgErrorKey]];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
    {
        [self performSelectorOnMainThread:@selector(handlePhotosError:)
                               withObject:parseError
                            waitUntilDone:NO];
    }
}

@end