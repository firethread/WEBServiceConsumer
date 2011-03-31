//
//  UserProfileResponse.h
//  WebServices
//
//  Created by Viktor Ignatov on 15/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSDLProtoClass.h"
#import "UserProfileResult.h"

@interface UserProfileResponse : WSDLProtoClass {

}

@property (nonatomic, retain) UserProfileResult *UserProfileResult;

@end
