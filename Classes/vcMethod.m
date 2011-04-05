//
//  vcMethod.m
//  WebServices
//
//  Created by Viktor Ignatov on 31/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "vcMethod.h"
#import "WSDLProtoClass.h"
#import "vcWEBObjectIspector.h"

@implementation vcMethod

@synthesize oWSDLReader, Scheme, ServiceName, oWSDLProtoClass, HeaderView, ListMethods, ListHeaders;

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
    [ServiceName release];
    [oWSDLProtoClass release];
    [HeaderView release];
    [ListMethods release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.oWSDLProtoClass = [self.oWSDLReader newWebClass:self.Scheme name: self.ServiceName];
    self.ListMethods = [[self.oWSDLProtoClass ProtoMethods] allKeys];
    self.ListHeaders = [[self.oWSDLProtoClass ProtoHeaders] allKeys];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.oWSDLProtoClass.ProtoMethods count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section < [self.oWSDLProtoClass.ProtoMethods count] ? 2 : [self.oWSDLProtoClass.ProtoHeaders count]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section       
{ 
    self.HeaderView = [[UIView alloc]init];
    [self.HeaderView setBackgroundColor:[UIColor whiteColor]];
    [self.HeaderView setBackgroundColor:[UIColor clearColor]];
    UILabel *HeaderText = [[UILabel alloc]init];
    [HeaderText setTextColor:[UIColor blackColor]];
    [HeaderText setBackgroundColor:[UIColor clearColor]];
    [HeaderText setFrame:CGRectMake(0, 0, 100, 25)];
    if (section < [self.oWSDLProtoClass.ProtoMethods count]) {
        HeaderText.text = [[self.oWSDLProtoClass.ProtoMethods allKeys] objectAtIndex:section];
    }
    else {
        HeaderText.text = @"<Headers>";        
    }
    [self.HeaderView addSubview:HeaderText];
    [HeaderText release];
    return self.HeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    WSDLProtoClass *Temp = nil;
    if (indexPath.section < [self.oWSDLProtoClass.ProtoMethods count]) {
        NSString *MethodName = [self.ListMethods objectAtIndex:indexPath.section];
        switch (indexPath.row) {
            case 0:
                Temp = [self.oWSDLProtoClass GetInputDataObject:MethodName];
                cell.textLabel.text = [Temp VirtualClassName];
                break;
            case 1:
                Temp = [self.oWSDLProtoClass GetOutputDataObject:MethodName];
                cell.textLabel.text = [Temp VirtualClassName];
                break;
        }
    }
    else {
        NSString *MethodName = [self.ListHeaders objectAtIndex:indexPath.row];
        Temp = [self.oWSDLProtoClass GetInputHeaderObject:MethodName];
        cell.textLabel.text = [Temp VirtualClassName];
    }
    [Temp release];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    vcWEBObjectIspector *detailViewController = [[vcWEBObjectIspector alloc] initWithNibName:@"vcWEBObjectIspector" bundle:nil];

    detailViewController.oWSDLReader = self.oWSDLReader;
    
    WSDLProtoClass *Temp = nil;
    if (indexPath.section < [self.oWSDLProtoClass.ProtoMethods count]) {
        NSString *MethodName = [self.ListMethods objectAtIndex:indexPath.section];
        switch (indexPath.row) {
            case 0:
                Temp = [self.oWSDLProtoClass GetInputDataObject:MethodName];
                break;
            case 1:
                Temp = [self.oWSDLProtoClass GetOutputDataObject:MethodName];
                break;
        }
    }
    else {
        NSString *MethodName = [self.ListHeaders objectAtIndex:indexPath.row];
        Temp = [self.oWSDLProtoClass GetInputHeaderObject:MethodName];
    }
    detailViewController.oWSDLProtoClass = Temp;
    detailViewController.IsArrayData = false;
    [Temp release];

    [self.navigationController pushViewController:detailViewController animated:YES];
    [vcWEBObjectIspector release];
}

@end
