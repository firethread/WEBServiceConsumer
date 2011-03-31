//
//  WSDLReader.h
//  VelvetPay
//
//  Created by Viktor Ignatov on 25/02/2011.
//  Copyright 2011 © ILoveVelvet inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLElement.h"
#import "WSDLProtoClass.h"

@interface WSDLReader : NSObject {
	XMLElement *WSDL;
}

@property (nonatomic, retain) XMLElement *WSDL;

+ (WSDLReader *) newWSDLReaderWithURL:(NSURL *) url;
+ (WSDLReader *) newWSDLReaderWithFileName:(NSString *) filename;
+ (WSDLReader *) newWSDLReaderWithURLOrFileName:(NSURL *) url filename:(NSString *) filename forceFromURL:(bool)forceFromURL;

- (XMLElement *) schTypes;
- (XMLElement *) schSchema:(NSString *) schema;
- (XMLElement *) wsdl_Service;
- (XMLElement *) soap_ServiceURL:(NSString *)ClassName;

- (WSDLProtoClass *) newProtoObject:(NSString *) className;
- (NSString *) excludeTagNamePrefix:(NSString *) tagName;
- (bool) isSimpleTypeName:(NSString *) typeName;
- (bool) isTypeIsArray:(NSString *) typeName;

- (XMLElement *) GetBaseTypeTag:(NSString *)schema name:(NSString *)name;
- (WSDLProtoClass *) newGetProtoClassFromMessage:(NSString *)schema MessageName:(NSString *) MessageName;

- (WSDLProtoClass *) newComplexTypeOrElement:(NSString *)schema name:(NSString *)name IsArray:(bool) IsArray;
- (WSDLProtoClass *) newWebClass:(NSString *)schema name:(NSString *)name;
@end
