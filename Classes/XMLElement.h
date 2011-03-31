//
//  XMLElement.h
//  VelvetPay
//
//  Created by Viktor Ignatov on 18/02/2011.
//  Copyright 2011 © ILoveVelvet inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XMLElementDelegate
@optional 
- (void) XMLElementParserError:(NSXMLParser *)parser;
@end


@interface XMLElement : NSObject<NSXMLParserDelegate> {
	id delegate;
	
	NSString *TagName;
	NSMutableDictionary *Attributes;
	NSMutableArray *newSubElementList;
	NSString *Text;
	NSString *Prefix;
	NSString *Namespace;
	XMLElement *parentElement;
	
	@private
	XMLElement *CurrentElement;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSString *TagName;
@property (nonatomic, retain) NSMutableDictionary *Attributes;
@property (nonatomic, retain) NSMutableArray *newSubElementList;
@property (nonatomic, retain) NSString *Text;
@property (nonatomic, retain) NSString *CDataText;
@property (nonatomic, retain) NSString *Prefix;
@property (nonatomic, retain) NSString *Namespace;
@property (nonatomic, retain) XMLElement *parentElement;

+ (XMLElement *) newElementWithString:(NSString *) xmlString _delegate:(id) _delegate;

+ (XMLElement *) newElementWithTagName:(NSString *) xmlString _delegate:(id)_delegate;

- (void) CreateTree:(NSString *) xmlString;

- (XMLElement *) root;

- (XMLElement *) newSubElementByTagName:(NSString *) tagName recursive:(bool) recursive;
- (XMLElement *) newSubElementByCondition:(NSPredicate *) Condition recursive:(bool) recursive;

- (NSArray *) newSubElementsByTagName:(NSString *) tagName recursive:(bool) recursive;
- (NSArray *) newSubElementsByCondition:(NSPredicate *) Condition recursive:(bool) recursive;

- (XMLElement *) addnewSubElement:(NSString *) tagName;

- (NSString *) getXMLString:(bool) recursive;

- (NSString *) getXMLString:(bool) recursive xmlVertion:(bool) xmlVertion;

- (NSString *) CDataText;
- (void) setCDataText:(NSString *) Value;

- (void) clean;
@end
