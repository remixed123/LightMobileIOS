//
//  SSConfigViewController.m
//  lightcontroller
//
//  Created by Glenn Vassallo on 3/09/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SSConfigViewController.h"
#import "SSUtilities.h"
#import "SSGlobalSettings.h"
#import "GCDAsyncSocket.h"
#import "testflight/TestFlight.h"

@interface SSConfigViewController ()

@end

@implementation SSConfigViewController

@synthesize connectNowButton;           // the button to connect to the dmx server
@synthesize ipAddressText;
@synthesize portNumberText;
@synthesize versionText;

#pragma mark Connection Methods________________________________

- (IBAction)connectNow:(id)sender
{
    self.statusDescription.text = @"Connecting";
    SSGlobalSettings *connSettings = [SSGlobalSettings sharedManager];
    connSettings.ipAddress = self.ipAddressText.text;
    connSettings.portNumber = [self.portNumberText.text intValue];
    
    [[NSUserDefaults standardUserDefaults]setObject:connSettings.ipAddress forKey:@"ipAddress"];
    [[NSUserDefaults standardUserDefaults]setInteger:connSettings.portNumber forKey:@"portNumber"];
    
    NSLog(@"connectNow: connSettings.ipAddress: %@", connSettings.ipAddress);
    NSLog(@"connectNow: connSettings.portNumber: %d", connSettings.portNumber);
    
    conn = [[SSConnection alloc] init];
    [conn initNetworkCommunication];
    
    self.statusDescription.text = @"Connected";
    
    [TestFlight passCheckpoint:@"CONFIG_CONNECT_NOW"];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Check to see if they have configured an IP Address yet, if not add message and set port yo default 8999
    
    SSGlobalSettings *connSettings = [SSGlobalSettings sharedManager];
    NSString *ipAddress = connSettings.ipAddress;
    int portNumber = connSettings.portNumber;
    
    if ([ipAddress isEqualToString:@""])
    {
        self.statusDescription.text = @"Enter Settings";
    }

    if (portNumber <= 0)
    {
        self.statusDescription.text = @"Enter Settings";
        [[NSUserDefaults standardUserDefaults]setInteger:8999 forKey:@"portNumber"];
    }
    
    //Fill in details for version, status, ip and port
    self.ipAddressText.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"ipAddress"];
    self.portNumberText.text = [NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"portNumber"]];
    
    
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    
    self.versionText.text = [NSString stringWithFormat:@"Version %@", version];
    
    _statusDescription.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _statusDescription.layer.borderWidth = 1.5;
    _statusDescription.layer.cornerRadius = 8;
    
    versionText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    versionText.layer.borderWidth = 1.5;
    versionText.layer.cornerRadius = 8;
    
   // Setup to dismiss the number or decimal pad
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    [TestFlight passCheckpoint:@"CONFIG"];
}


-(void)tap:(UITapGestureRecognizer *)gr
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
