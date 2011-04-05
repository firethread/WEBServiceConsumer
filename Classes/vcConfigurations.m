//
//  vcConfigurations.m
//  WebServices
//
//  Created by Viktor Ignatov on 31/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "vcConfigurations.h"
#import "vcServices.h"
#import "WSDLReader.h"
@implementation vcConfigurations

@synthesize TextUrl, FileName, Scheme;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [TextUrl release]; 
    [FileName release];
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
    [super viewDidLoad];
    UIBarButtonItem *RightButon = [[UIBarButtonItem alloc] initWithTitle:@"Inspect" 
                                                                   style:UIBarButtonItemStyleBordered 
                                                                  target:self 
                                                                  action:@selector(Inspect)];
    self.navigationItem.rightBarButtonItem = RightButon;
    [RightButon release];
    
    UIBarButtonItem *LeftButon = [[UIBarButtonItem alloc] initWithTitle:@"Back" 
                                                                  style:UIBarButtonItemStyleBordered 
                                                                 target:self 
                                                                 action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = LeftButon;
    [LeftButon release];
    
    self.TextUrl.delegate = self;
    self.FileName.delegate = self;
    
}

- (BOOL)textFieldShouldReturn:(UITextField*)theTextField {
    [self.TextUrl resignFirstResponder];
    [self.FileName resignFirstResponder];
    
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) Inspect 
{
    if (![self.TextUrl.text isEqualToString:@""]) {
        vcServices *WEBObjectIspector = [[vcServices alloc] initWithNibName:@"vcServices" bundle:nil];
        NSURL *oURL = [NSURL URLWithString:self.TextUrl.text];
        NSString *sFileName = ([self.FileName.text isEqualToString:@""] ? @"OldWSDL" : self.FileName.text);
        WSDLReader *oWSDLReader = [WSDLReader newWSDLReaderWithURLOrFileName:oURL filename:sFileName forceFromURL:true];
        WEBObjectIspector.oWSDLReader = oWSDLReader;
        WEBObjectIspector.Scheme = self.Scheme.text;
        [oWSDLReader release];
        [self.navigationController pushViewController:WEBObjectIspector animated:YES];
        [WEBObjectIspector release];
    }
    else if(![self.FileName.text isEqualToString:@""]) {
        vcServices *WEBObjectIspector = [[vcServices alloc] initWithNibName:@"vcServices" bundle:nil];
        WSDLReader *oWSDLReader = [WSDLReader newWSDLReaderWithFileName:self.FileName.text];
        WEBObjectIspector.oWSDLReader = oWSDLReader;
        WEBObjectIspector.Scheme = self.Scheme.text;
        [oWSDLReader release];
        [self.navigationController pushViewController:WEBObjectIspector animated:YES];
        [WEBObjectIspector release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must specify URL or file name to WSDL" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

- (void) Back 
{
    [self.navigationController popViewControllerAnimated:true];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
