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
    [super viewDidLoad];
}

- (IBAction) iboOk:(id) sender {
	[self ProtoObjectFromMessage];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

