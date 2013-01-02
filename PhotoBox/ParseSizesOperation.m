//
//  ParseOperation.m
//  PhotoBox
//
//  Created by Kristen Novak on 12/31/12.
//  Copyright (c) 2012 Kristen Novak. All rights reserved.
//

#import "ParseSizesOperation.h"
#import "PhotoSizesObject.h"

static NSString * const kPhotoElementName = @"photo";
static NSString * const kSizesElementName = @"sizes";
static NSString * const kSizeElementName = @"size";
static NSString * const kLabelAttributeName = @"label";
static NSString * const kWidthAttributeName = @"width";
static NSString * const kHeightAttributeName = @"height";
static NSString * const kSourceAttributeName = @"source";

NSString *kAddPhotoSizesNotif = @"kAddPhotoSizesNotif";
NSString *kPhotoSizesResultsKey = @"kPhotoSizesResultsKey";
NSString *kPhotoSizesErrorNotif = @"kPhotoSizesErrorNotif";
NSString *kPhotoSizesMsgErrorKey = @"kPhotoSizesMsgErrorKey";

@interface ParseSizesOperation () <NSXMLParserDelegate>

@property (nonatomic, copy) ArrayBlock completionHandler;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) PhotoSizesObject *workingEntry;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;

@end

@implementation ParseSizesOperation

@synthesize completionHandler, errorHandler, dataToParse, workingArray, workingEntry, workingPropertyString, elementsToParse, storingCharacterData;

- (id)initWithData:(NSData *)parseData completionHandler:(ArrayBlock)handler
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = parseData;
        self.completionHandler = handler;
        self.elementsToParse = [NSArray arrayWithObjects:kPhotoElementName, kSizesElementName, kLabelAttributeName, kWidthAttributeName, kHeightAttributeName, kSourceAttributeName, nil];
    }
    return self;
}

- (void)main
{
	self.workingArray = [NSMutableArray array];
    self.workingPropertyString = [NSMutableString string];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataToParse];
	[parser setDelegate:self];
    [parser parse];
	
	if (![self isCancelled])
    {
        self.completionHandler(self.workingArray);
    }
    
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
    
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                     namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName
                                     attributes:(NSDictionary *)attributeDict {
   
    if ([elementName isEqualToString:kSizesElementName]) {
        self.workingEntry = [[PhotoSizesObject alloc] init];
        storingCharacterData = YES;
    } else if ([elementName isEqualToString:kSizeElementName]) {
        
        NSString *labelAttribute = [attributeDict valueForKey:kLabelAttributeName];
        NSString *sourceAttribute = [attributeDict valueForKey:kSourceAttributeName];
        
        if ([[attributeDict valueForKey:kLabelAttributeName] isEqualToString:@"thumbnail"]){
            self.workingEntry.thumbnail = sourceAttribute;
        } else if ([[attributeDict valueForKey:kLabelAttributeName] isEqualToString:@"small"]){
            self.workingEntry.small = sourceAttribute;
        } else if ([[attributeDict valueForKey:kLabelAttributeName] isEqualToString:@"medium"]){
            self.workingEntry.medium = sourceAttribute;
        } else if ([[attributeDict valueForKey:kLabelAttributeName] isEqualToString:@"original"]){
            self.workingEntry.original = sourceAttribute;
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    
    if (self.workingEntry)
	{
        if ([elementName isEqualToString:kSizesElementName])
        {
            [self.workingArray addObject:self.workingEntry];
            
            parsedPhotosCounter++;
            
            self.workingEntry = nil;
        }
    }
    storingCharacterData = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (storingCharacterData) {
        [self.workingPropertyString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    self.errorHandler(parseError);
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
    {
        [self performSelectorOnMainThread:@selector(handlePhotosError:)
                               withObject:parseError
                            waitUntilDone:NO];
    }
}

- (void)handlePhotosError:(NSError *)parseError {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoSizesErrorNotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:parseError
                                                                                           forKey:kPhotoSizesMsgErrorKey]];
}


- (void)addPhotosToList:(NSArray *)photos {
    assert([NSThread isMainThread]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddPhotoSizesNotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:photos
                                                                                           forKey:kPhotoSizesResultsKey]];
}   

@end