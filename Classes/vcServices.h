//
//  vcServices.h
//  WebServices
//
//  Created by Viktor Ignatov on 31/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSDLReader.h"

@interface vcServices : UITableViewController {
    WSDLReader *oWSDLReader;
    NSArray *ListServices;
    NSString *Scheme;
}

@property (nonatomic, retain) WSDLReader *oWSDLReader;
@property (nonatomic, retain) NSString *Scheme;

@end
