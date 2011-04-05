//
//  vcWEBObjectIspector.h
//  WebServices
//
//  Created by Viktor Ignatov on 31/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSDLReader.h"

@interface vcWEBObjectIspector : UITableViewController<UIAlertViewDelegate> {
    WSDLReader *oWSDLReader;
    id oWSDLProtoClass;
    NSArray *ListProperties;
    bool IsArrayData;
}

@property (nonatomic, retain) WSDLReader *oWSDLReader;
@property (nonatomic, retain) id oWSDLProtoClass;
@property (nonatomic, retain) NSArray *ListProperties;
@property (nonatomic, readwrite) bool IsArrayData;

@end
