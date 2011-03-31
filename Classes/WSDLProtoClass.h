//
//  WSDLProtoClass.h
//  VelvetPay
//
//  Created by Viktor Ignatov on 25/02/2011.
//  Copyright 2011 © ILoveVelvet inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLElement.h"

@interface WSDLProtoClass : NSObject<NSCopying> {
	//Service for executing
	NSString *ServiceURL;
	
	//Class / Type name.
	NSString *VirtualClassName;
	
	//key / value - name of the property / array{Type (classname can be ProtoClass), value (id)}.
	NSMutableDictionary *ProtoProperties;
	
	//key / value - name of the method / object.
	NSMutableDictionary *ProtoMethods;
	
	//Object for header message.
	//key / value - name of the method / object.
	NSMutableDictionary *ProtoHeaders;
	
	//soap actions.
	NSString *soapAction;
	
	bool IsArrayData;
}

@property (nonatomic, retain) NSString *ServiceURL;
@property (nonatomic, retain) NSString *VirtualClassName;
@property (nonatomic, retain) NSMutableDictionary *ProtoProperties;
@property (nonatomic, retain) NSMutableDictionary *ProtoMethods;
@property (nonatomic, retain) NSMutableDictionary *ProtoHeaders;
@property (nonatomic, retain) NSString *soapAction;
@property (nonatomic, readwrite) bool IsArrayData;

- (id) GetPropertyValue:(NSString *)name;
- (void) SetPropertyValue:(NSString *)name value:(id) value;

- (WSDLProtoClass *) GetInputHeaderObject:(NSString *)MethodName;
- (WSDLProtoClass *) GetInputDataObject:(NSString *)MethodName;
- (WSDLProtoClass *) GetOutputDataObject:(NSString *)MethodName;

- (id) ExecuteMethod:(NSString *)name RootMethodParameter:(WSDLProtoClass *)RootMethodParameter oHeader:(WSDLProtoClass *)oHeader;

- (bool) isSimpleTypeName:(NSString *) typeName;

- (NSString *) GetSOAPTypeXMLValue:(NSArray *) Data;
- (XMLElement *) GetSOAPFromProtoClass:(XMLElement *) Element Object:(WSDLProtoClass *)Object;
- (WSDLProtoClass *) GetProtoClassFromSOAP:(XMLElement *) Element Object:(WSDLProtoClass *)BaseObjectStructure ArrayElement:(bool) ArrayElement;
- (WSDLProtoClass *) AddNewItem;
- (void) PrepareList;

- (XMLElement *) SendRequest:(XMLElement *) POSTData WEBMethodName:(NSString *)WEBMethodName;

id protoPropertyIMP(id self, SEL _cmd, id Data, id Header);
- (id) DinamicPropertyValue:(NSString *)cmdStrValue Data:(id) Data Header:(id) Header;

- (void) clean;
@end
