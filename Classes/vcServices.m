//
//  vcServices.m
//  WebServices
//
//  Created by Viktor Ignatov on 31/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "vcServices.h"
#import "vcMethod.h"

@implementation vcServices

@synthesize oWSDLReader, Scheme;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [oWSDLReader release];
    [Scheme release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    ListServices = [self.oWSDLReader.WSDL newSubElementsByTagName:@"wsdl:service" recursive:false];
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ListServices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[[ListServices objectAtIndex:indexPath.row] Attributes] objectForKey:@"name"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    vcMethod *detailViewController = [[vcMethod alloc] initWithNibName:@"vcMethod" bundle:nil];
    
    NSString *key = [[[ListServices objectAtIndex:indexPath.row] Attributes] objectForKey:@"name"];
    detailViewController.Scheme = self.Scheme;
    detailViewController.ServiceName = key;
    detailViewController.oWSDLReader = self.oWSDLReader;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

@end
