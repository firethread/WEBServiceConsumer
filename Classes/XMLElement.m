//
//  XMLElement.m
//  VelvetPay
//
//  Created by Viktor Ignatov on 18/02/2011.
//  Copyright 2011 © ILoveVelvet inc. All rights reserved.
//

#import "XMLElement.h"

@implementation XMLElement

@synthesize TagName, Attributes, newSubElementList, Text, CDataText, Prefix, Namespace, parentElement, delegate;

+ (XMLElement *) newElementWithString:(NSString *) xmlString _delegate:(id)_delegate {
	XMLElement *element = [[XMLElement alloc] init];
	element.delegate = _delegate;
	[element CreateTree:xmlString];
	
	return element;
}

+ (XMLElement *) newElementWithTagName:(NSString *) xmlString _delegate:(id)_delegate {
	XMLElement *element = [[XMLElement alloc] init];
	element.delegate = _delegate;
	[element CreateTree:[NSString stringWithFormat:@"<%@/>", xmlString]];
	
	return element;
}

- (void) CreateTree:(NSString *) xmlString {
	NSXMLParser *myParser = [[NSXMLParser alloc] initWithData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
	[myParser setDelegate:self];
	[myParser setShouldProcessNamespaces:NO];
	[myParser setShouldReportNamespacePrefixes:NO];
	[myParser setShouldResolveExternalEntities:NO];
	[myParser parse];
	[myParser release];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(XMLElementParserError:)]) {
		[delegate XMLElementParserError:parser];
	}
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	if (self.TagName == nil) {
		CurrentElement = self;
		CurrentElement.parentElement = nil;
	}
	else {
		XMLElement *TempElement = [[XMLElement alloc] init];
		TempElement.parentElement = CurrentElement;
		[CurrentElement.newSubElementList addObject:TempElement];
		CurrentElement = TempElement;
	}

	//NSLog(@"%i", [[[oGarbageCollectionContainer sharedoGarbageCollectionContainer] Collection] count]);
	
	CurrentElement.TagName = elementName;
	CurrentElement.Attributes = [[NSMutableDictionary alloc] initWithDictionary:attributeDict copyItems:true];
	[CurrentElement.Attributes release];
	CurrentElement.newSubElementList = [[NSMutableArray alloc] init];
	[CurrentElement.newSubElementList release];
	CurrentElement.Namespace = namespaceURI;
	CurrentElement.Prefix = qName;
	
	//NSLog(@"Begin tag %@ = %i", CurrentElement.TagName, [CurrentElement retainCount]);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	//NSLog(@"End tag %@ = %i", CurrentElement.TagName, [CurrentElement retainCount]);
	if (CurrentElement.parentElement != nil ) {
		[CurrentElement release];
		CurrentElement = CurrentElement.parentElement;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	CurrentElement.Text = string;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	//[CurrentElement release];
}

- (XMLElement *) root {
	XMLElement *Temp = self;
	
	while (Temp.parentElement != nil) {
		[Temp release];
		Temp = Temp.parentElement;
	}
	
	return Temp;
}

//[NSPredicate predicateWithFormat:@"TagName == \"???\""]
//[NSPredicate predicateWithFormat:@"Attributes[\"name\"] == \"value\""]
- (XMLElement *) SubElementByCondition:(NSPredicate *) Condition recursive:(bool) recursive {
	XMLElement *Temp = nil;
	NSArray *Elements = [self newSubElementsByCondition:Condition recursive:recursive];
	
	if (Elements != nil && [Elements count] > 0) {
		Temp = [Elements objectAtIndex:0];
	}

	[Elements release];
	return Temp;
}

- (XMLElement *) SubElementByTagName:(NSString *) tagName recursive:(bool) recursive {
	NSPredicate *Condition = [NSPredicate predicateWithFormat:@"TagName == %@", tagName];
	return [self SubElementByCondition:Condition recursive:recursive];
}

//[NSPredicate predicateWithFormat:@"TagName == \"???\""]
//[NSPredicate predicateWithFormat:@"Attributes[\"name\"] == \"value\""]
- (NSArray *) newSubElementsByCondition:(NSPredicate *) Condition recursive:(bool) recursive {
	NSMutableArray *Temp = [[NSMutableArray alloc]init];
	
	for (XMLElement* Item in self.newSubElementList) {
		if ([Condition evaluateWithObject:Item]) {
			[Temp addObject:Item];
		}
	}
	if (recursive) {
		for (XMLElement* Item in self.newSubElementList) {
            NSArray *TempItem = [Item newSubElementsByCondition:Condition recursive:recursive];
			[Temp addObject:TempItem];
            [TempItem release];
		}
	}
	return Temp;
}

- (NSArray *) newSubElementsByTagName:(NSString *) tagName recursive:(bool) recursive {
	NSPredicate *Condition = [NSPredicate predicateWithFormat:@"TagName == %@", tagName];
	
	return [self newSubElementsByCondition:Condition recursive:recursive];
}

- (XMLElement *) addnewSubElement:(NSString *) tagName {
	XMLElement *Temp = [XMLElement newElementWithTagName:tagName _delegate:self.delegate];
	[self.newSubElementList addObject:Temp];
	[Temp release];
	return Temp;
}

- (NSString *) getXMLString:(bool) recursive {
	NSString *Temp = nil;
	
	Temp = [NSString stringWithFormat:@"<%@", self.TagName];
	
	for (NSString *Item in self.Attributes) {
		Temp = [NSString stringWithFormat:@"%@ %@=\"%@\"", Temp, Item, [self.Attributes objectForKey:Item]];
	}
	
	Temp = [NSString stringWithFormat:@"%@>", Temp];
	
	if (recursive) {
		for (XMLElement* Item in self.newSubElementList) {
			Temp = [NSString stringWithFormat:@"%@%@", Temp, [Item getXMLString:recursive]];
		}
	}
	
	if (self.Text != nil) {
		Temp = [NSString stringWithFormat:@"%@%@", Temp, self.Text];
	}
	
	Temp = [NSString stringWithFormat:@"%@</%@>", Temp, self.TagName];
	
	return Temp;
}

- (NSString *) getXMLString:(bool) recursive xmlVertion:(bool) xmlVertion {
	return [NSString stringWithFormat:@"%@%@", (xmlVertion ? @"<?xml version=\"1.0\" encoding=\"utf-8\"?>" : @""), xmlVertion];
}

- (NSString *) CDataText {
	NSRange beginCD = [self.Text rangeOfString:@"<![CData["];
	NSRange endCD = [self.Text rangeOfString:@"]]>"];
	
	NSMutableString *RetData = [NSMutableString stringWithString:self.Text];
	
	if (!NSEqualRanges(NSMakeRange(NSNotFound, 0), beginCD)) {
		[RetData deleteCharactersInRange:beginCD];
		[RetData deleteCharactersInRange:endCD];
	}
	
	return RetData;
}
- (void) setCDataText:(NSString *) Value {
	self.Text = [NSString stringWithFormat:@"<![CData[%@]]>", Value];
}

- (void) clean {
	for (int ii = [self.newSubElementList count] - 1; ii >= 0; ii--) {
		XMLElement *item = [self.newSubElementList objectAtIndex:ii];
		[item clean];
		[self.newSubElementList removeLastObject];
	}
}

- (void)dealloc {
	[delegate release];
	[TagName release];
	[Attributes release];
	[newSubElementList release];
	[Text release];
	[parentElement release];
	if (CurrentElement != self && CurrentElement != nil) {
		[CurrentElement release];		
	}
		
    [super dealloc];
}

@end
