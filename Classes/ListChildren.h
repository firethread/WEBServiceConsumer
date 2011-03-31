//
//  ArrayOfChildren.h
//  WebServices
//
//  Created by Viktor Ignatov on 16/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSDLProtoClass.h"
#import "Children.h"

@interface ListChildren : WSDLProtoClass {

}

@property (nonatomic, retain) NSMutableArray *ArrayOfChildren;

@end
