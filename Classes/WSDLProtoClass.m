//
//  WSDLProtoClass.m
//  VelvetPay
//
//  Created by Viktor Ignatov on 25/02/2011.
//  Copyright 2011 © ILoveVelvet inc. All rights reserved.
//

#import "WSDLProtoClass.h"
#import "WSDLReader.h"
#include <objc/runtime.h>

@implementation WSDLProtoClass

@synthesize ServiceURL, VirtualClassName, ProtoProperties, ProtoMethods, ProtoHeaders, soapAction, IsArrayData;

- (id)init {
    if ( ![super init] ) {
		return nil;
	}
	
	ProtoProperties = [[NSMutableDictionary alloc]init];
	ProtoMethods = [[NSMutableDictionary alloc]init];
	ProtoHeaders = [[NSMutableDictionary alloc]init];

	soapAction = @"http://ims.isc-bg.com/services/v1.1";
	
	IsArrayData = false;
	
	return self;
}

+ (BOOL) resolveInstanceMethod:(SEL)aSEL {
    class_addMethod([self class], aSEL, (IMP) protoPropertyIMP, "v@:");
	return YES;
}

- (id) copyWithZone: (NSZone *) zone {
    WSDLProtoClass *newItem = [[[self class] allocWithZone:zone] init];
	
	[newItem setIsArrayData: IsArrayData];
	
	NSString *strTemp = nil;
	strTemp = [ServiceURL copy];
	[newItem setServiceURL: strTemp];
	[strTemp release];
	strTemp = [VirtualClassName copy];
	[newItem setVirtualClassName: strTemp];
	[strTemp release];
	
	strTemp = [soapAction copy];
	[newItem setSoapAction: strTemp];
	[strTemp release];
	
	for (NSString *key in ProtoMethods) {
		NSArray *parameters = [ProtoMethods objectForKey:key];
		NSArray *newParameters = [NSArray arrayWithObjects:[[parameters objectAtIndex:0] copy], [[parameters objectAtIndex:1] copy], nil];
		[newItem.ProtoMethods setObject:newParameters forKey:key];
		//[newParameters release];
	}
	
	for (NSString *key in ProtoHeaders) {
		WSDLProtoClass *newParameter = [[ProtoHeaders objectForKey:key] copy];
		[newItem.ProtoHeaders setObject:newParameter forKey:key];
		[newParameter release];
	}
	
	for (NSString *key in ProtoProperties) {
		NSArray *parameters = [ProtoProperties objectForKey:key];
		id Param1 = [[parameters objectAtIndex:0] copy];
		id Param2 = nil;
		if (self.IsArrayData) {
			Param2 = [[NSMutableArray alloc] init];
			NSArray *aSubParameters = [parameters objectAtIndex:1];
			for (id Item in aSubParameters) {
				id TempItem = [Item copy];
				[Param2 addObject:TempItem];
				[TempItem release];
			}
		}
		else {
			Param2 = [[parameters objectAtIndex:1] copy];
		}
		
		NSArray *newParameters = [[NSArray alloc] initWithObjects:Param1, Param2, nil];
		[newItem.ProtoProperties setObject:newParameters forKey:key];
		[newParameters release];
		[Param2 release];
	}
	
    return(newItem);
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

- (id) GetPropertyValue:(NSString *)name {
	NSArray *Data = [self.ProtoProperties objectForKey:name];
	id ResultData = nil;
	
	if ([Data count] >= 2) {
		if ([self isSimpleTypeName:[Data objectAtIndex:0]]) {
			ResultData = [Data objectAtIndex:1];
		}
		else {
			id Value = [Data objectAtIndex:1];
			if (self.IsArrayData) {
				ResultData = Value;
			}
			else {
				if ([Value isKindOfClass:[WSDLProtoClass class]]) {
					ResultData = Value;
				}
				else {
					ResultData = (WSDLProtoClass *)[[NSClassFromString([Data objectAtIndex:0]) alloc] init];
					
					if (ResultData == nil) {
						ResultData = [[WSDLProtoClass alloc] init];
					}
					
					[self SetPropertyValue:name value:ResultData];
				}
			}
		}
	}

	return ResultData;
}

- (void) SetPropertyValue:(NSString *)name value:(id) value {
	NSArray *Data = nil;
	NSArray *Desc = [self.ProtoProperties objectForKey:name];
	if ([value isKindOfClass:[WSDLProtoClass class]]) {
		Data = [NSArray arrayWithObjects:NSStringFromClass([value class]), value, nil];
	}
	else {
		if ([[Desc objectAtIndex:0] isEqualToString:@"string"]) {
			Data = [NSArray arrayWithObjects:@"string", value, nil];
		}
		else if ([[Desc objectAtIndex:0] isEqualToString:@"dateTime"]) {
			Data = [NSArray arrayWithObjects:@"dateTime", value, nil];
		}
		else if ([[Desc objectAtIndex:0] isEqualToString:@"double"] ||
				 [[Desc objectAtIndex:0] isEqualToString:@"decimal"] ||
				 [[Desc objectAtIndex:0] isEqualToString:@"float"]) {
			Data = [NSArray arrayWithObjects:@"decimal", value, nil];
		}
		else if ([[Desc objectAtIndex:0] isEqualToString:@"integer"] ||
				 [[Desc objectAtIndex:0] isEqualToString:@"int"]) {
			Data = [NSArray arrayWithObjects:@"int", value, nil];
		}
		else if ([[Desc objectAtIndex:0] isEqualToString:@"boolean"] ||
				 [[Desc objectAtIndex:0] isEqualToString:@"bool"]) {
			Data = [NSArray arrayWithObjects:@"bool", value, nil];
		}
	}
	[self.ProtoProperties setValue:Data forKey:name];
}

- (WSDLProtoClass *) GetInputHeaderObject:(NSString *)MethodName {
	WSDLProtoClass *oInputH = [self.ProtoHeaders objectForKey:MethodName];
	
	return [oInputH copy];
}

- (WSDLProtoClass *) GetInputDataObject:(NSString *)MethodName {
	NSArray *parameters = [self.ProtoMethods objectForKey:MethodName];
	WSDLProtoClass *oInput = [parameters objectAtIndex:1];
	
	return [oInput copy];
}

- (WSDLProtoClass *) GetOutputDataObject:(NSString *)MethodName {
	NSArray *parameters = [self.ProtoMethods objectForKey:MethodName];
	WSDLProtoClass *oOutput = [parameters objectAtIndex:0];
	
	return [oOutput copy];
}

- (NSString *) GetSOAPTypeXMLValue:(NSArray *) Data {
	NSString *Temp = nil;
	
	if ([[Data objectAtIndex:0] isEqualToString:@"string"]) {
		Temp = [[Data objectAtIndex:1] copy];
	} 
	else if ([[Data objectAtIndex:0] isEqualToString:@"double"] ||
			 [[Data objectAtIndex:0] isEqualToString:@"decimal"] ||
			 [[Data objectAtIndex:0] isEqualToString:@"float"] ) {
		Temp = [NSString stringWithFormat:@"%1.2f", [[Data objectAtIndex:1] doubleValue]];
	}
	else if ([[Data objectAtIndex:0] isEqualToString:@"integer"] ||
			 [[Data objectAtIndex:0] isEqualToString:@"int"]) {
		Temp = [NSString stringWithFormat:@"%i", [[Data objectAtIndex:1] intValue]];
	}
	else if ([[Data objectAtIndex:0] isEqualToString:@"boolean"] ||
			 [[Data objectAtIndex:0] isEqualToString:@"bool"]) {
		Temp = [NSString stringWithFormat:@"%@", ([[Data objectAtIndex:1] intValue] ? @"true" : @"false")];
	}
	else if ([[Data objectAtIndex:0] isEqualToString:@"dateTime"]) {
		NSDateFormatter *formater = [[NSDateFormatter alloc] init];
		[formater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZ"];
		NSMutableString *TempStr = [NSMutableString stringWithString: [formater stringFromDate:[Data objectAtIndex:1]]];
		[TempStr insertString:@":" atIndex:[TempStr length] - 2];
		Temp = TempStr;
		[formater release];
	}
	
	return Temp;
}

- (id) GetObjectTypeFromSOAPTypeXML:(NSArray *) Data {
	id Temp = nil;
	
	if ([[Data objectAtIndex:0] isEqualToString:@"string"]) {
		Temp = [[Data objectAtIndex:1] copy];
	} 
	else if ([[Data objectAtIndex:0] isEqualToString:@"double"] ||
			 [[Data objectAtIndex:0] isEqualToString:@"decimal"] ||
			 [[Data objectAtIndex:0] isEqualToString:@"float"] ) {
		Temp = [NSNumber numberWithDouble:[[Data objectAtIndex:1] doubleValue]];
	}
	else if ([[Data objectAtIndex:0] isEqualToString:@"integer"] ||
			 [[Data objectAtIndex:0] isEqualToString:@"int"]) {
		Temp = [NSNumber numberWithDouble:[[Data objectAtIndex:1] intValue]];
	}
	else if ([[Data objectAtIndex:0] isEqualToString:@"boolean"] ||
			 [[Data objectAtIndex:0] isEqualToString:@"bool"]) {
		Temp = [NSNumber numberWithDouble:([[Data objectAtIndex:1] isEqualToString:@"true"] ? 1 : 0 )];
	}
	else if ([[Data objectAtIndex:0] isEqualToString:@"dateTime"]) {
		NSDateFormatter *formater = [[NSDateFormatter alloc] init];
		[formater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZ"];
		NSMutableString *TempStr = [NSMutableString stringWithString: [Data objectAtIndex:1]];
		[TempStr deleteCharactersInRange:NSMakeRange([TempStr length] - 3, 1)];
		Temp = [formater dateFromString:TempStr];
		[formater release];
	}
	
	return Temp;
}

- (WSDLProtoClass *) GetProtoClass:(XMLElement *)soapResult {
	WSDLProtoClass *Temp = self;
	
	for (XMLElement *Item in soapResult.newSubElementList) {
		NSArray *arguments = [self.ProtoProperties objectForKey:Item.TagName];
		NSString *ArgName = [[arguments objectAtIndex:0] copy];
		NSString *ArgValue = [Item.Text copy];
		
		if ([ArgName isEqualToString:@"string"]) {
			arguments = [NSArray arrayWithObjects:ArgName, ArgValue, nil];
			[self.ProtoProperties setObject:arguments forKey:Item.TagName];
			[arguments release];
		} 
		else if ([ArgName isEqualToString:@"double"] ||
				 [ArgName isEqualToString:@"decimal"] ||
				 [ArgName isEqualToString:@"float"] ) {
			arguments = [NSArray arrayWithObjects:ArgName, [NSNumber numberWithDouble: [ArgValue doubleValue]], nil];
			[self.ProtoProperties setObject:arguments forKey:Item.TagName];
			[arguments release];
		}
		else if ([ArgName isEqualToString:@"integer"] || 
				 [ArgName isEqualToString:@"int"]) {
			arguments = [NSArray arrayWithObjects:ArgName, [NSNumber numberWithInt: [ArgValue intValue]], nil];
			[self.ProtoProperties setObject:arguments forKey:Item.TagName];
		}
		else if ([ArgName isEqualToString:@"boolean"] ||
				 [ArgName isEqualToString:@"bool"]) {
			arguments = [NSArray arrayWithObjects:ArgName, [NSNumber numberWithInt: ([ArgValue isEqualToString:@"true"] ? 1 : 0 )], nil];
			[self.ProtoProperties setObject:arguments forKey:Item.TagName];
			[arguments release];
		}
		else if ([ArgName isEqualToString:@"dateTime"]) {
			NSDateFormatter *formater = [[NSDateFormatter alloc] init];
			[formater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZ"];
			NSMutableString *TempStr =[NSMutableString stringWithString:ArgValue];
			[TempStr deleteCharactersInRange:NSMakeRange([TempStr length] - 2, 1)];
			arguments = [NSArray arrayWithObjects:ArgName, [formater dateFromString:TempStr], nil];
			[self.ProtoProperties setObject:arguments forKey:Item.TagName];
			[formater release];
			[arguments release];
		}
		else {
			WSDLProtoClass *TempSubClass = [arguments objectAtIndex:1];
			[Temp SetPropertyValue:ArgName value:[TempSubClass GetProtoClass:Item]];
		}
	}
	
	return Temp;
}

- (XMLElement *) GetSOAPFromProtoClass:(XMLElement *) Element Object:(WSDLProtoClass *)Object {
	//ElementBased
	
	for (NSString *key in Object.ProtoProperties) {
		NSArray *SubParameters = [Object.ProtoProperties objectForKey:key];
		if ([self isSimpleTypeName:[SubParameters objectAtIndex:0]]) {
			XMLElement *ParElement = [Element addnewSubElement:key];
			ParElement.Text = [self GetSOAPTypeXMLValue:SubParameters];
		}
		else {
			if (Object.IsArrayData) {
				for (id item in [SubParameters objectAtIndex:1]) {
					if ([self isSimpleTypeName:[SubParameters objectAtIndex:0]]) {
						XMLElement *ParElement = [Element addnewSubElement:[SubParameters objectAtIndex:0]];
						[self GetSOAPFromProtoClass:ParElement Object:item];
					}
					else {
						XMLElement *ParElement = [Element addnewSubElement:[item VirtualClassName]];
						[self GetSOAPFromProtoClass:ParElement Object:item];
					}
				}
			}
			else {
				XMLElement *ParElement = [Element addnewSubElement:key];
				[self GetSOAPFromProtoClass:ParElement Object:[SubParameters objectAtIndex:1]];
			}
		}
	}
	
	return Element;
}

- (WSDLProtoClass *) GetProtoClassFromSOAP:(XMLElement *) Element Object:(WSDLProtoClass *)BaseObjectStructure ArrayElement:(bool) ArrayElement {
	WSDLProtoClass *ProtoClassObject = nil;
	NSArray *baseParameters = nil;
	
	if (ArrayElement) {
		baseParameters = [[NSArray alloc] initWithObjects:BaseObjectStructure.VirtualClassName, BaseObjectStructure, nil];
		//[BaseObjectStructure.VirtualClassName release];
		//[BaseObjectStructure release];
	}
	else {
		baseParameters = [BaseObjectStructure.ProtoProperties objectForKey:Element.TagName];
		[baseParameters retain];
	}

	if ([baseParameters count] >= 2) {
		WSDLProtoClass *baseParameterObject = [baseParameters objectAtIndex:1];
		
		if ([self isSimpleTypeName:[baseParameters objectAtIndex:0]]) {
			NSString *ClassName = [[baseParameters objectAtIndex:0] copy];
			NSArray* Objectparameters = [NSArray arrayWithObjects:ClassName, Element.Text, nil];
			ProtoClassObject = [self GetObjectTypeFromSOAPTypeXML:Objectparameters];
		}
		else {
			ProtoClassObject = [baseParameterObject copy];
			[ProtoClassObject clean];
			
			for (NSString *key in [[baseParameters objectAtIndex:1] ProtoProperties]) {
				XMLElement *ElementData = [Element SubElementByTagName:key recursive:false];
				NSArray *parameters = [[[baseParameters objectAtIndex:1] ProtoProperties] objectForKey:key];
				NSString *ClassName = [[parameters objectAtIndex:0] copy];
				
				if ([self isSimpleTypeName:ClassName]) {
					NSArray* Objectparameters = [NSArray arrayWithObjects:ClassName, ElementData.Text, nil];
					id TempObject = [self GetObjectTypeFromSOAPTypeXML:Objectparameters];
					NSArray *SubObjectDesc = [NSArray arrayWithObjects:ClassName, TempObject, nil];
					[ClassName release];
					[ProtoClassObject.ProtoProperties setObject:SubObjectDesc
														 forKey:key];
				}
				else {
					if (ProtoClassObject.IsArrayData) {
						NSMutableArray *List = [[NSMutableArray alloc]init];
						NSArray *TempParameters = [[[baseParameters objectAtIndex:1] ProtoProperties] objectForKey:key];
						WSDLProtoClass *TempObject = [[TempParameters objectAtIndex:1] objectAtIndex:0];
						NSArray *SumElementList = [Element newSubElementList];
						
						for (XMLElement *SubItem in SumElementList) {
							WSDLProtoClass *TempSubObject = [self GetProtoClassFromSOAP:SubItem 
																				 Object:TempObject
																		   ArrayElement:true];
							[List addObject:TempSubObject];
							[TempSubObject release];
						}
						NSArray *ListParametersArray = [NSArray arrayWithObjects:ClassName, List, nil];
						[ClassName release];
						[ProtoClassObject.ProtoProperties setObject:ListParametersArray
															 forKey:key];
						[List release];
					}
					else {
						WSDLProtoClass *TempObject = [self GetProtoClassFromSOAP:ElementData Object:[baseParameters objectAtIndex:1] ArrayElement:false];
						NSArray *SubObjectDesc = [NSArray arrayWithObjects:ClassName, TempObject, nil];
						[ClassName release];
						[TempObject release];
						[ProtoClassObject.ProtoProperties setObject:SubObjectDesc
															 forKey:key];
					}
				}
				[ClassName release];
			}
		}
	}
	
	[baseParameters release];
	
	return ProtoClassObject;
}

- (WSDLProtoClass *) AddNewItem {
	NSMutableArray *oList = nil;
	NSString *ZeroElement = nil;
	WSDLProtoClass *Temp = nil;
	NSArray *kays = [self.ProtoProperties allKeys];
	
	if ([kays count] > 0) {
		if (self.IsArrayData) {
			ZeroElement = [kays objectAtIndex:0];
			oList = [self GetPropertyValue:ZeroElement];
			Temp = [[oList objectAtIndex:0] copy];
			[oList addObject:Temp];
			[Temp release];
		}
	}
	
	return Temp;
}

- (void) PrepareList {
	NSArray *Keys = [self.ProtoProperties allKeys];
	
	if ([Keys count] > 0) {
		NSString *ArrayOfChildren = [Keys objectAtIndex:0];
		
		if (self.IsArrayData) {
			NSMutableArray *oList = [self GetPropertyValue:ArrayOfChildren];
			WSDLProtoClass *Temp = [oList objectAtIndex:0];
			//[Temp release];
			[oList removeObject:Temp];
		}
	}
}

- (id) ExecuteMethod:(NSString *)name RootMethodParameter:(WSDLProtoClass *)RootMethodParameter oHeader:(WSDLProtoClass *)oHeader {
	XMLElement *Root = [XMLElement newElementWithTagName:@"soap12:Envelope" _delegate:nil];
	
	[Root.Attributes setValue:@"http://www.w3.org/2001/XMLSchema-instance" forKey:@"xmlns:xsi"];
	[Root.Attributes setValue:@"http://www.w3.org/2001/XMLSchema" forKey:@"xmlns:xsd"];
	[Root.Attributes setValue:@"http://www.w3.org/2003/05/soap-envelope" forKey:@"xmlns:soap12"];

	if (oHeader == nil) {
		oHeader = [self.ProtoHeaders objectForKey:name];
	}

	if (oHeader != nil) {
		XMLElement *Header = [Root addnewSubElement:@"soap12:Header"];
		if ([oHeader isKindOfClass: [WSDLProtoClass class]]) {
			XMLElement *RootHeaderTag = [Header addnewSubElement:oHeader.VirtualClassName];
			[self GetSOAPFromProtoClass:RootHeaderTag Object:oHeader];
			[RootHeaderTag.Attributes setValue:self.soapAction forKey:@"xmlns"];
		}
	}

	XMLElement *Body = [Root addnewSubElement:@"soap12:Body"];
	
	NSArray *parameters = [self.ProtoMethods objectForKey:name];
	
	XMLElement *RootMethodTag = [Body addnewSubElement:name];
	[RootMethodTag.Attributes setValue:self.soapAction forKey:@"xmlns"];
	
	if (RootMethodParameter == nil) {
		RootMethodParameter = [parameters objectAtIndex:1];
	}
	
	[self GetSOAPFromProtoClass:RootMethodTag Object:RootMethodParameter];

	XMLElement *ResponseRoot = [self SendRequest:Root WEBMethodName:name];
	
	[Root clean];
	[Root release];

	XMLElement *ResponseBody = [ResponseRoot SubElementByTagName:@"soap12:Body" recursive:false];
	if (ResponseBody == nil) {
		ResponseBody = [ResponseRoot SubElementByTagName:@"soap:Body" recursive:false];
	}
	XMLElement *xmlResponse = [ResponseBody SubElementByTagName:[NSString stringWithFormat:@"%@Response", name] recursive:false];
	XMLElement *xmlResult = [xmlResponse SubElementByTagName:[NSString stringWithFormat:@"%@Result", name] recursive:false];
	
	NSString *ResultName = [NSString stringWithFormat:@"%@Result", name];
	
	WSDLProtoClass *tmpResponse = [self GetOutputDataObject:name];
	
	NSString *tmpResultType = [[tmpResponse.ProtoProperties objectForKey:ResultName] objectAtIndex:0];
	WSDLProtoClass *tmpResultObject = [self GetProtoClassFromSOAP:xmlResult Object:tmpResponse ArrayElement:false];
	
	[tmpResponse clean];
	
	NSArray *tmpResultData = [NSArray arrayWithObjects: tmpResultType, tmpResultObject, nil];
	
	[tmpResultObject release];
	[tmpResultType release];
	
	[tmpResponse.ProtoProperties setValue: tmpResultData forKey:ResultName];

	//[tmpResultData release];

	[ResponseRoot clean];
	[ResponseRoot release];
	
	return tmpResponse;
}

- (XMLElement *) SendRequest:(XMLElement *) POSTData WEBMethodName:(NSString *)WEBMethodName {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:self.ServiceURL]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField: @"Content-Type"];
	[request addValue:[NSString stringWithFormat:@"%@%@", self.soapAction, WEBMethodName] forHTTPHeaderField: @"SOAPAction"];
	
	NSString *XML = [POSTData getXMLString:true];
	[request setHTTPBody:[XML dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSLog(@"request = %@", XML);
	
	NSError *error = nil;
	NSURLResponse *response = nil;

	NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[request release];
	
	NSString *Temp = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	XMLElement *XMLResponse = [XMLElement newElementWithString:Temp _delegate:nil];
	
	NSLog(@"response %@", Temp);

	[Temp release];
	return XMLResponse;
}

- (id) DinamicPropertyValue:(NSString *)cmdStrValue Data:(id) Data Header:(id) Header {
	NSString *Temp = nil;
	NSString *First = [cmdStrValue substringToIndex:3];
	NSString *Last = [cmdStrValue substringFromIndex:[cmdStrValue length] - 1];
	NSRange range = [cmdStrValue rangeOfString:@":"];
	id DataResult = nil;
	
	if (![First isEqualToString:@"set"] &&
		!NSEqualRanges(NSMakeRange(NSNotFound, 0), range)) {
		Temp = [cmdStrValue substringToIndex:range.location];
	}
	NSArray *Kays = [self.ProtoMethods allKeys];
	if ([Kays containsObject:Temp]) {
		DataResult = [self ExecuteMethod:Temp RootMethodParameter:Data oHeader:Header];
	}
	else {
		if ([First isEqualToString:@"set"] && 
			[Last isEqualToString:@":"]) {
			Temp = [cmdStrValue substringFromIndex:3];
			Temp = [Temp substringToIndex:[Temp length] - 1];
			
			[self SetPropertyValue:Temp value:Data];
		}
		else {
			DataResult = [self GetPropertyValue:cmdStrValue];
		}
	}
	
	return DataResult;
}

id protoPropertyIMP(id self, SEL _cmd, id Data, id Header) {
	id Res = [self DinamicPropertyValue:NSStringFromSelector(_cmd) Data: Data Header: Header];
	return Res;
}

- (void) clean {
	for (NSString *key in self.ProtoMethods) {
		[self.ProtoMethods removeObjectForKey:key];
	}
	NSArray *keyes = [self.ProtoProperties allKeys];
	for (NSString *key in keyes) {
		[self.ProtoProperties removeObjectForKey:key];
	}
	for (NSString *key in self.ProtoHeaders) {
		[self.ProtoHeaders removeObjectForKey:key];
	}
}

- (void)dealloc {
	//[self clean];
	
	[ServiceURL release];
	[VirtualClassName release];
	
	[ProtoProperties release];
	[ProtoMethods release];
	[ProtoHeaders release];

	[soapAction release];
	
    [super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"VirtualClassName = %@, soapAction = %@, ServiceURL = %@ retainCounter = %i", self.VirtualClassName, self.soapAction, self.ServiceURL, [self retainCount]];
}
@end
