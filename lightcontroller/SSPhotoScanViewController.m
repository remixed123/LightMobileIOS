//
//  SSPhotoScanViewController.m
//  LightMobile
//
//  Created by Glenn Vassallo on 15/09/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import "SSPhotoScanViewController.h"

@interface SSPhotoScanViewController ()

@end

@implementation SSPhotoScanViewController

@synthesize imageView;
@synthesize image;
@synthesize view;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) endPhotoScan:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
