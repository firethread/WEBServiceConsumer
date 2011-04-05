//
//  RootViewController.m
//  WebServices
//
//  Created by Viktor Ignatov on 15/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "WSDLReader.h"

#import "Service.h"

#import "UserProfile.h"
#import "UserProfileData.h"
#import "UserProfileResponse.h"
#import "UserProfileResult.h"

#import "AuthHeader.h"

#import "XMLElement.h"

#import "vcConfigurations.h"

@implementation RootViewController

#pragma mark -
#pragma mark View lifecycle

- (void) ProtoObjectFromMessage {
	//WSDLReader *wsdl = [WSDLReader newWSDLReaderWithURL:[NSURL URLWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"WSDL_URL"]]];
	WSDLReader *wsdl = [WSDLReader newWSDLReaderWithURLOrFileName:[NSURL URLWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"WSDL_URL"]] filename:@"OldWSDL" forceFromURL:false];

	NSLog(@"%@", [wsdl.WSDL getXMLString:true]);
	
	Service *protoClass = (Service *)[wsdl newWebClass:@"s" name:@"Service"];
	UserProfile *oUserProfile = (UserProfile *)[protoClass GetInputDataObject:@"UserProfile"];

	UserProfileData *oUserProfileData = [oUserProfile UserProfileData];
	
	[oUserProfileData setUserName: @"Toni"];
	[oUserProfileData setAge: [NSNumber numberWithInt:35]];
	[oUserProfileData setMoney: [NSNumber numberWithDouble:1000.52]];
	[oUserProfileData setBirthDay: [NSDate date]];
	[oUserProfileData setMarried: [NSNumber numberWithInt:0]];
	[oUserProfileData setSex:@"Woman"];
	
	ListChildren *oListChildren = [oUserProfileData ListChildren];
	
	Children *oChildren1 = (Children *)[oListChildren AddNewItem];
	[oChildren1 setName:@"Tedo"];
	[oChildren1 setAge:[NSNumber numberWithInt:10]];
	[oChildren1 setBirthDay:[NSDate date]];
	
	Children *oChildren2 = (Children *)[oListChildren AddNewItem];
	[oChildren2 setName:@"Serj"];
	[oChildren2 setAge:[NSNumber numberWithInt:11]];
	[oChildren2 setBirthDay:[NSDate date]];

	Children *oChildren3 = (Children *)[oListChildren AddNewItem];
	[oChildren3 setName:@"Bongo"];
	[oChildren3 setAge:[NSNumber numberWithInt:1]];
	[oChildren3 setBirthDay:[NSDate date]];
	[oListChildren PrepareList];
	
	AuthHeader *oAuthHeader = (AuthHeader *)[protoClass GetInputHeaderObject:@"AuthHeader"];
	
	oAuthHeader.UserName = @"vicho";
	oAuthHeader.Password = @"Opala";
	
	UserProfileResponse *response = (UserProfileResponse *)[protoClass UserProfile:oUserProfile oHeader:oAuthHeader];

	//NSLog(@"UserProfileResult = %@", [response UserProfileResult]);
	
	UserProfileResult *result = [response UserProfileResult];
	
	NSLog(@"UserName = %@", [result UserName]);
	NSLog(@"Age = %i", [[result Age]intValue]);
	NSLog(@"Money = %1.2f", [[result Money]doubleValue]);
	NSLog(@"Married = %@", [result Married]);
	NSLog(@"Sex = %@", [result Sex]);
	NSLog(@"BirthDay = %@", [result BirthDay]);
	
	ListChildren *oListChildrenR = [result ListChildren];
	NSArray *oChildrenR = [oListChildrenR ArrayOfChildren];
	for (Children *Item in oChildrenR) {
		NSLog(@"Name = %@", [Item Name]);
		NSLog(@"Age = %i", [[Item Age]intValue]);
		NSLog(@"BirthDay = %@", [Item BirthDay]);
	}

	[response release];
	[oUserProfile release];
	[oAuthHeader release];
	[protoClass release];
	[wsdl release];
}

- (void)viewDidLoad {
    UIBarButtonItem *RightButon = [[UIBarButtonItem alloc] initWithTitle:@"Config WSDL path" style:UIBarButtonItemStyleBordered target:self action:@selector(Configuration)];

    self.navigationItem.rightBarButtonItem = RightButon;
    [RightButon release];
    
    [super viewDidLoad];
}

- (void) Configuration {
    vcConfigurations *Configurations = [[vcConfigurations alloc] initWithNibName:@"vcConfigurations" bundle:nil];
    [self.navigationController pushViewController:Configurations animated:YES];
    [Configurations release];
}

- (IBAction) iboOk:(id) sender {
	[self ProtoObjectFromMessage];
}


- (void)dealloc {
    [super dealloc];
}


@end

