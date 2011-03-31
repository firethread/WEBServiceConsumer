//
//  HelloWorld.h
//  VelvetPay
//
//  Created by Viktor Ignatov on 14/03/2011.
//  Copyright 2011 © ILoveVelvet inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSDLProtoClass.h"

@protocol HelloWorldDelegate
@optional 
- (WSDLProtoClass *) UserProfile:(WSDLProtoClass *)RootMethodParameter oHeader:(WSDLProtoClass *)oHeader;
- (WSDLProtoClass *) UserProfile2:(WSDLProtoClass *)RootMethodParameter oHeader:(WSDLProtoClass *)oHeader;
@end

@interface Service : WSDLProtoClass<HelloWorldDelegate> {

}

@end
