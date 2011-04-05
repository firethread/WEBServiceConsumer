//
//  vcMethod.h
//  WebServices
//
//  Created by Viktor Ignatov on 31/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSDLReader.h"

@interface vcMethod : UITableViewController {
    WSDLReader *oWSDLReader;
    NSString *Scheme;
    NSString *ServiceName;
    NSArray *ListMethods;
    NSArray *ListHeaders;
    WSDLProtoClass *oWSDLProtoClass;
    UIView *HeaderView;
}

@property (nonatomic, retain) WSDLReader *oWSDLReader;
@property (nonatomic, retain) NSString *Scheme;
@property (nonatomic, retain) NSString *ServiceName;
@property (nonatomic, retain) WSDLProtoClass *oWSDLProtoClass;
@property (nonatomic, retain) NSArray *ListMethods;
@property (nonatomic, retain) NSArray *ListHeaders;

@property (nonatomic, retain) UIView *HeaderView;

@end
