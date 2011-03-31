//
//  UserProfileResult.h
//  WebServices
//
//  Created by Viktor Ignatov on 15/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSDLProtoClass.h"
#import "ListChildren.h"

@interface UserProfileResult : WSDLProtoClass {

}

@property (nonatomic, retain) NSString *UserName;
@property (nonatomic, retain) NSNumber *Age;
@property (nonatomic, retain) NSNumber *Money;
@property (nonatomic, retain) NSDate *BirthDay;
@property (nonatomic, retain) NSNumber *Married;
@property (nonatomic, retain) NSString *Sex;
@property (nonatomic, retain) ListChildren *ListChildren;

@end
