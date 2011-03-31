//
//  AuthHeader.h
//  WebServices
//
//  Created by Viktor Ignatov on 30/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSDLProtoClass.h"

@interface AuthHeader : WSDLProtoClass {

}

@property (nonatomic, retain) NSString *UserName;
@property (nonatomic, retain) NSString *Password;

@end
