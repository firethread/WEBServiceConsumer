//
//  vcWEBObjectIspector.m
//  WebServices
//
//  Created by Viktor Ignatov on 31/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "vcWEBObjectIspector.h"
#import "WSDLProtoClass.h"

@implementation vcWEBObjectIspector

@synthesize oWSDLReader, oWSDLProtoClass, ListProperties, IsArrayData;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //
    }
    return self;
}

- (void)dealloc
{
    [oWSDLReader release];
    [oWSDLProtoClass release];
    [ListProperties release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    if (!self.IsArrayData) {
        self.ListProperties = [((WSDLProtoClass *)self.oWSDLProtoClass).ProtoProperties allKeys];
    }
    else {
        self.ListProperties = self.oWSDLProtoClass;
    }
    
    [super viewDidLoad];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ListProperties count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *ParameterName = nil;
    NSString *ParameterType = nil;
    
    if (self.IsArrayData) {
        ParameterName = ((WSDLProtoClass *)[self.ListProperties objectAtIndex:indexPath.row]).VirtualClassName;
        ParameterType = ((WSDLProtoClass *)[self.ListProperties objectAtIndex:indexPath.row]).VirtualClassName;
    }
    else {
        ParameterName = [self.ListProperties objectAtIndex:indexPath.row];
        ParameterType = [[[self.oWSDLProtoClass ProtoProperties] objectForKey:ParameterName] objectAtIndex:0];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", ParameterName, ParameterType];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *PropertyName = [self.ListProperties objectAtIndex:indexPath.row];
    NSArray *params = nil;
    if (self.IsArrayData) {
        params = [[[self.oWSDLProtoClass objectAtIndex:0] ProtoProperties] objectForKey:PropertyName];
    }
    else {
        params = [[self.oWSDLProtoClass ProtoProperties] objectForKey:PropertyName];
    }
        
    if (![self.oWSDLReader isSimpleTypeName:[params objectAtIndex:0]]) {
        vcWEBObjectIspector *detailViewController = [[vcWEBObjectIspector alloc] initWithNibName:@"vcWEBObjectIspector" bundle:nil];
        detailViewController.oWSDLReader = self.oWSDLReader;
        if (self.IsArrayData) {
            WSDLProtoClass *Temp = [((NSArray *)self.oWSDLProtoClass) objectAtIndex:indexPath.row];
            detailViewController.oWSDLProtoClass = Temp;
            detailViewController.IsArrayData = Temp.IsArrayData;
        }
        else {
            WSDLProtoClass *Temp = [((WSDLProtoClass *)self.oWSDLProtoClass) GetPropertyValue:PropertyName];
            detailViewController.oWSDLProtoClass = Temp;
            detailViewController.IsArrayData = ((WSDLProtoClass *)self.oWSDLProtoClass).IsArrayData;
        }
        
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];   
    }
}

@end
