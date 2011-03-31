//
//  Children.h
//  WebServices
//
//  Created by Viktor Ignatov on 16/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSDLProtoClass.h"

@interface Children : WSDLProtoClass {

}

@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) NSNumber *Age;
@property (nonatomic, retain) NSDate *BirthDay;

@end
