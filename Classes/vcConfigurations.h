//
//  vcConfigurations.h
//  WebServices
//
//  Created by Viktor Ignatov on 31/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface vcConfigurations : UIViewController<UITextFieldDelegate> {
    UITextField *TextUrl;
    UITextField *FileName;
    UITextField *Scheme;
}

@property (nonatomic, retain) IBOutlet UITextField *TextUrl;
@property (nonatomic, retain) IBOutlet UITextField *FileName;
@property (nonatomic, retain) IBOutlet UITextField *Scheme;

@end
