//
//  SSPhotoScanViewController.m
//  LightMobile
//
//  Created by Glenn Vassallo on 15/09/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SSPhotoScanViewController.h"
#import "SSUtilities.h"
#import "SSConnection.h"
#import "testflight/TestFlight.h"

@interface SSPhotoScanViewController ()

@end

@implementation SSPhotoScanViewController

int slowDownCount = 1;
static int effectType = 1;

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
    colorCodes=[[NSMutableDictionary alloc] init];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [view setUserInteractionEnabled:YES];
    [imageView setUserInteractionEnabled:YES];
    
    //////////////////////////////////////////////
    // Connection Configuration
    //////////////////////////////////////////////
    conn = [[SSConnection alloc] init];
    utils = [[SSUtilities alloc] init];
    
////// Test Flight Stuff
[TestFlight passCheckpoint:@"PHOTO_SCAN_CP1"];
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    conn = [[SSConnection alloc] init];
    utils = [[SSUtilities alloc] init];
    
    NSLog(@"touchesBegan");
    
    UITouch *touch=[touches anyObject];
    CGPoint pt=[touch locationInView:self.view];
       
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -pt.x, -pt.y);
    
    [self.view.layer renderInContext:context];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);    
    
    NSLog(@"colorOfPoint: red: %i : green: %i : blue: %i", pixel[0], pixel[1], pixel[2]);
    
    int redInt = [[NSString stringWithFormat:@"%i",pixel[0]] intValue];
    int greenInt = [[NSString stringWithFormat:@"%i",pixel[1]] intValue];
    int blueInt = [[NSString stringWithFormat:@"%i",pixel[2]] intValue];
    
    NSString *colorHex;
    colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];

    NSLog(@"colorOfPoint: colorHex: %@", colorHex);
    
    [self sendSingleColor:colorHex];

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesMoved");
    
    if (slowDownCount % 3 == 0)
    {
    UITouch *touch=[touches anyObject];
    CGPoint pt=[touch locationInView:self.view];
    
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -pt.x, -pt.y);
    
    [self.view.layer renderInContext:context];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    NSLog(@"colorOfPoint: red: %i : green: %i : blue: %i", pixel[0], pixel[1], pixel[2]);
    
    int redInt = [[NSString stringWithFormat:@"%i",pixel[0]] intValue];
    int greenInt = [[NSString stringWithFormat:@"%i",pixel[1]] intValue];
    int blueInt = [[NSString stringWithFormat:@"%i",pixel[2]] intValue];
    
    NSString *colorHex;
    colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
    NSLog(@"colorOfPoint: colorHex: %@", colorHex);
    [self sendSingleColor:colorHex];
        
        slowDownCount = 0;
    }
    slowDownCount = slowDownCount + 1;
    
}

-(void)sendSingleColor :(NSString*) colorHex
{
    NSString *lwdpPacket;
    if (effectType == 1) //change all colors at the same time
    {
    lwdpPacket = [utils createLwdpPacket:@"11" :colorHex];  //Using LWDPr - Light Weight Data Protocol Reduced
    [conn sendPacket:lwdpPacket];
    }
    else if (effectType == 2) //use the push effect
    {
        NSString *hexTimeSeperation = @"0000";
        NSString *hexStripeCount = @"00";
        NSString *hexEffectType = @"0002";
        
        NSString *payLoad = [NSString stringWithFormat:@"%@%@%@%@",hexEffectType,hexTimeSeperation,hexStripeCount,colorHex];
        
        NSLog(@"sendPacket: hexEffectType: %@, hexTimeSeperation: %@, hexStripeCount: %@, colorHex: %@",hexEffectType,hexTimeSeperation,hexStripeCount,colorHex);
        
        NSString *lwdpPacket = [utils createLwdpPacket:@"50" :payLoad];
        
        NSLog(@"sendPacket: lwdpPacket: %@", lwdpPacket);
        
        [conn sendPacket:lwdpPacket];
    }
    
    NSLog(@"sendSingleColor: lwdpPacket: %@", lwdpPacket);
}

- (IBAction)effect1:(id)sender
{
    effectType = 1;
}

- (IBAction)effect2:(id)sender
{
    effectType = 2;
}

@end
