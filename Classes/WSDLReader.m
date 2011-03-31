//
//  WSDLReader.m
//  VelvetPay
//
//  Created by Viktor Ignatov on 25/02/2011.
//  Copyright 2011 © ILoveVelvet inc. All rights reserved.
//

#import "WSDLReader.h"

@implementation WSDLReader

@synthesize WSDL;

+ (WSDLReader *) newWSDLReaderWithURL:(NSURL *) url {
	WSDLReader *WSDLTemp = [[WSDLReader alloc] init];
	NSError *error = nil;
	XMLElement *xmlTemp = [XMLElement newElementWithString:[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error] _delegate:self];
	WSDLTemp.WSDL = xmlTemp;
	[xmlTemp release];
	return WSDLTemp;
}

+ (WSDLReader *) newWSDLReaderWithFileName:(NSString *) filename {
	filename = [NSTemporaryDirectory() stringByAppendingPathComponent: filename];
	WSDLReader *WSDLTemp = [[WSDLReader alloc] init];
	NSError *error = nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
		WSDLTemp.WSDL = [XMLElement newElementWithString:[NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&error] _delegate:self];
		[WSDLTemp.WSDL release];
	}
	return WSDLTemp;
}

+ (WSDLReader *) newWSDLReaderWithURLOrFileName:(NSURL *) url filename:(NSString *) filename forceFromURL:(bool)forceFromURL {
	NSString *tempfilename = [NSTemporaryDirectory() stringByAppendingPathComponent: filename];
	if (forceFromURL || ![[NSFileManager defaultManager] fileExistsAtPath:tempfilename]) {
		NSError *error = nil;
		NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
		[content writeToFile:tempfilename atomically:true encoding:NSUTF8StringEncoding error:&error];
	}
	return [WSDLReader newWSDLReaderWithFileName:filename];
}

- (XMLElement *) schTypes {
	return [WSDL newSubElementByTagName:@"wsdl:types" recursive:false];
}

- (XMLElement *) schSchema:(NSString *) schema {
	return [[self schTypes] newSubElementByTagName:[NSString stringWithFormat:@"%@:schema", schema] recursive:false];
}

- (XMLElement *) wsdl_Service {
	return [WSDL newSubElementByTagName:@"wsdl:service" recursive:false];
}

- (XMLElement *) soap_ServiceURL:(NSString *)ClassName {
	NSPredicate *Condition = nil;
	XMLElement *Port = nil;
	
	Condition = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"TagName == \"wsdl:port\" AND Attributes[\"name\"]==\"%@Soap12\"", ClassName]];
	Port = [[self wsdl_Service] newSubElementByCondition:Condition recursive:false];
	
	if (Port == nil) {
		Condition = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"TagName == \"wsdl:port\" AND Attributes[\"name\"]==\"%@Soap\"", ClassName]];
		Port = [[self wsdl_Service] newSubElementByCondition:Condition recursive:false];
	}
	
	XMLElement *Address = [Port newSubElementByTagName:@"soap12:address" recursive:false];
	if (Address == nil) {
		Address = [Port newSubElementByTagName:@"soap:address" recursive:false];
	}
	
	return Address;
}

- (WSDLProtoClass *) newProtoObject:(NSString *) className {
	WSDLProtoClass *ProtoObject = nil;
	
	if (NSClassFromString(className) == nil) {
		ProtoObject = [[WSDLProtoClass alloc] init];
	}
	else {
		ProtoObject = (WSDLProtoClass *)[[NSClassFromString(className) alloc] init];
	}

	ProtoObject.VirtualClassName = className;
	
	return ProtoObject;
}

- (NSString *) excludeTagNamePrefix:(NSString *) tagName {
	NSRange range = [tagName rangeOfString:@":"];
	NSString *SubString = nil;
	
	if (!NSEqualRanges(NSMakeRange(NSNotFound, 0), range)) {
		NSString *strTemp = [tagName substringFromIndex:range.location + 1];
		SubString = [NSString stringWithString:strTemp];
	}
	else {
		SubString = [NSString stringWithString:tagName];
	}
		
	return SubString;
}

- (bool) isTypeIsArray:(NSString *) typeName {
	NSString *strTemp = [self excludeTagNamePrefix:typeName];
	NSRange range = [strTemp rangeOfString:@"ArrayOf"];
	bool IsArray = NSEqualRanges(NSMakeRange(NSNotFound, 0), range);
	//[strTemp release];
	return !IsArray;
}

- (bool) isSimpleTypeName:(NSString *) typeName {
	return
		[typeName isEqualToString:@"string"] ||
		[typeName isEqualToString:@"double"] ||
		[typeName isEqualToString:@"decimal"] ||
		[typeName isEqualToString:@"float"] ||
		[typeName isEqualToString:@"integer"] ||
		[typeName isEqualToString:@"int"] ||
		[typeName isEqualToString:@"boolean"] ||
		[typeName isEqualToString:@"bool"] ||
		//[typeName isEqualToString:@"date"] ||
		//[typeName isEqualToString:@"time"] ||
		[typeName isEqualToString:@"dateTime"];
}

- (XMLElement *) GetBaseTypeTag:(NSString *)schema name:(NSString *)name {
	NSPredicate *Condition = nil;
	XMLElement *ComplexType = nil;
	XMLElement *Schema = [self schSchema:schema];

	Condition = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"TagName == \"%@:complexType\" AND Attributes[\"name\"]==\"%@\"", schema, name]];
	ComplexType = [Schema newSubElementByCondition:Condition recursive:false];
	
	if (ComplexType == nil) {
		Condition = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"TagName == \"%@:element\" AND Attributes[\"name\"]==\"%@\"", schema, name]];
		ComplexType = [Schema newSubElementByCondition:Condition recursive:false];
	}

	return ComplexType;
}

- (WSDLProtoClass *) newComplexTypeOrElement:(NSString *)schema name:(NSString *)name IsArray:(bool) IsArray {
	XMLElement *ComplexType = [self GetBaseTypeTag:schema name:name];
	WSDLProtoClass *ProtoObject = nil;

	if (ComplexType != nil) {
		ProtoObject = [self newProtoObject:name];
		
		XMLElement *ComplexContent = [ComplexType newSubElementByTagName:[NSString stringWithFormat:@"%@:complexContent", schema] recursive:false];
		XMLElement *Sequence = nil;
		NSString *extensionBaseTypeName = nil;
		if (ComplexContent != nil) {
			XMLElement *extension = [ComplexContent newSubElementByTagName:[NSString stringWithFormat:@"%@:extension", schema] recursive:false];
			Sequence = [extension newSubElementByTagName:[NSString stringWithFormat:@"%@:sequence", schema] recursive:false];
			extensionBaseTypeName = [self excludeTagNamePrefix: [extension.Attributes objectForKey:@"base"]];
		}
		else {
			Sequence = [ComplexContent newSubElementByTagName:[NSString stringWithFormat:@"%@:sequence", schema] recursive:false];
			if (Sequence == nil) {
				Sequence = [ComplexType newSubElementByTagName:[NSString stringWithFormat:@"%@:sequence", schema] recursive:false];
			}
		}
		
		if (Sequence == nil) {
			ComplexContent = [ComplexType newSubElementByTagName:[NSString stringWithFormat:@"%@:complexType", schema] recursive:false];
			Sequence = [ComplexContent newSubElementByTagName:[NSString stringWithFormat:@"%@:sequence", schema] recursive:false];
		}
		
		if (Sequence != nil) {
			NSArray *SequenceElementList = [Sequence newSubElementsByTagName:[NSString stringWithFormat:@"%@:element", schema] recursive:false];
			for (XMLElement *SimpleItem in SequenceElementList) {
				NSString *strType = [self excludeTagNamePrefix: [SimpleItem.Attributes objectForKey:@"type"]];
				NSArray *Data = nil;
				
				if ([self isSimpleTypeName:strType]) {
					if (IsArray) {
						NSArray *SubData = [NSArray arrayWithObjects:strType, nil];
						Data = [NSArray arrayWithObjects:strType, SubData, nil];
						ProtoObject.IsArrayData = true;
						[ProtoObject.ProtoProperties setValue:Data forKey:name];
					}
					else {
						Data = [NSArray arrayWithObjects:strType, strType, nil];
						[ProtoObject.ProtoProperties setValue:Data forKey:[SimpleItem.Attributes objectForKey:@"name"]];
					}
				}
				else {
					WSDLProtoClass *TempSubObject = [self newComplexTypeOrElement:schema name:strType IsArray:[self isTypeIsArray:strType]];
					if (IsArray) {
						NSArray *SubData = [NSArray arrayWithObjects:TempSubObject, nil];
						Data = [NSArray arrayWithObjects:strType, SubData, nil];
						ProtoObject.IsArrayData = true;
						[ProtoObject.ProtoProperties setValue:Data forKey:name];
					}
					else {
						Data = [NSArray arrayWithObjects:strType, TempSubObject, nil];
						[ProtoObject.ProtoProperties setValue:Data forKey:[SimpleItem.Attributes objectForKey:@"name"]];
					}
					[TempSubObject release];
				}
			}
			[SequenceElementList release];
			if (extensionBaseTypeName != nil) {
				WSDLProtoClass *Temp = [self newComplexTypeOrElement:schema name:extensionBaseTypeName IsArray:false];
				
				for (NSString *kay in Temp.ProtoProperties) {
					id ItemTemp = [[Temp.ProtoProperties objectForKey:kay] copy];
					[ProtoObject.ProtoProperties setValue:ItemTemp forKey:kay];
					[ItemTemp release];
				}
				[Temp release];
			}
		}
	}

	return ProtoObject;
}

- (WSDLProtoClass *) newGetProtoClassFromMessage:(NSString *)schema MessageName:(NSString *) MessageName {
	NSPredicate *Condition = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"TagName == \"wsdl:message\" AND Attributes[\"name\"]==\"%@\"", [self excludeTagNamePrefix:MessageName]]];
	XMLElement *Message = [WSDL newSubElementByCondition:Condition recursive:false];
	WSDLProtoClass *ProtoObject = nil;
	if (Message != nil) {
		XMLElement *Part = [Message newSubElementByTagName:@"wsdl:part" recursive:false];
		if (Part != nil) {
			NSString *strTemp = [self excludeTagNamePrefix:[Part.Attributes objectForKey:@"element"]];
			bool IsArray = [self isTypeIsArray:strTemp];
			ProtoObject = [self newComplexTypeOrElement:schema name:strTemp IsArray:IsArray];
			//[strTemp release];
		}
	}
	return ProtoObject;
}

- (WSDLProtoClass *) newWebClass:(NSString *)schema name:(NSString *)name {
	WSDLProtoClass *ProtoObject = [self newProtoObject:name];
	
	ProtoObject.ServiceURL = [[self soap_ServiceURL:name].Attributes objectForKey:@"location"];
	ProtoObject.soapAction = [WSDL.Attributes objectForKey:@"targetNamespace"];
	
	NSPredicate *Condition = nil;
	XMLElement *Binding = nil;

	//Header
	Condition = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"TagName == \"wsdl:binding\" AND Attributes[\"name\"]==\"%@Soap12\"", name]];
	Binding = [self.WSDL newSubElementByCondition:Condition recursive:false];
	if (Binding == nil) {
		Condition = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"TagName == \"wsdl:binding\" AND Attributes[\"name\"]==\"%@Soap\"", name]];
		Binding = [[self wsdl_Service] newSubElementByCondition:Condition recursive:false];
	}
	if (Binding != nil) {
		NSArray *TempList = [Binding newSubElementsByTagName:@"wsdl:operation" recursive:false];
		for (XMLElement *Operation in TempList) {
			XMLElement *Input = [Operation newSubElementByTagName:@"wsdl:input" recursive:false];
			if (Input != nil) {
				XMLElement *Header = [Input newSubElementByTagName:@"soap12:header" recursive:false];
				
				if (Header == nil) {
					Header = [Input newSubElementByTagName:@"soap:header" recursive:false];
				}
				
				if (Header != nil) {
					NSString *MessageName = [Header.Attributes objectForKey:@"message"];
					WSDLProtoClass *oHeader = [self newGetProtoClassFromMessage:schema MessageName:MessageName];
					[ProtoObject.ProtoHeaders setValue:oHeader forKey:[Header.Attributes objectForKey:@"part"]];
					[oHeader release];
				}
			}
		}
		[TempList release];
	}

	//Parameters
	Condition = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"TagName == \"wsdl:portType\" AND Attributes[\"name\"]==\"%@Soap12\"", name]];
	XMLElement *PortType = [self.WSDL newSubElementByCondition:Condition recursive:false];
	if (PortType == nil) {
		Condition = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"TagName == \"wsdl:portType\" AND Attributes[\"name\"]==\"%@Soap\"", name]];
		PortType = [self.WSDL newSubElementByCondition:Condition recursive:false];
	}
	if (PortType != nil) {
		NSArray *TempList = [PortType newSubElementsByTagName:@"wsdl:operation" recursive:false];
		for (XMLElement *operationItem in TempList) {
			XMLElement *input = [operationItem newSubElementByTagName:@"wsdl:input" recursive:false];
			XMLElement *output = [operationItem newSubElementByTagName:@"wsdl:output" recursive:false];
			NSMutableArray *arguments = [[NSMutableArray alloc] init];
			
			WSDLProtoClass *TempMessage;

			NSString *strTemp;
			strTemp = [self excludeTagNamePrefix:[output.Attributes objectForKey:@"message"]];
			TempMessage = [self newGetProtoClassFromMessage:schema MessageName:strTemp];
			[arguments addObject:TempMessage];
			[TempMessage release];
			//[strTemp release];
			
			strTemp = [self excludeTagNamePrefix:[input.Attributes objectForKey:@"message"]];
			TempMessage = [self newGetProtoClassFromMessage:schema MessageName:strTemp];
			[arguments addObject:TempMessage];
			[TempMessage release];
			//[strTemp release];

			[ProtoObject.ProtoMethods setValue:arguments forKey:[operationItem.Attributes valueForKey:@"name"]];
			
			[arguments release];
		}
		[TempList release];
	}
	
	return ProtoObject;
}

- (void)dealloc {
	[WSDL clean];
	[WSDL release];
	
    [super dealloc];
}

@end
