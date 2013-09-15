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

@interface SSPhotoScanViewController ()

@end

@implementation SSPhotoScanViewController

int slowDownCount = 1;

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


- (NSDictionary*)colorOfPoint:(CGPoint)point
{
//    NSLog(@"colorOfPoint");
//    
//    unsigned char pixel[4] = {0};
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
//    
//    CGContextTranslateCTM(context, -point.x, -point.y);
//    
//    [self.view.layer renderInContext:context];
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    
//    NSDictionary *rgbDic=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",pixel[0]],@"r",[NSString stringWithFormat:@"%i",pixel[1]],@"g",[NSString stringWithFormat:@"%i",pixel[2]],@"b",nil];
//    
//    [colorCodes setValue:rgbDic forKey:@"rgbCode"];
//    
//    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
//    [self.colorView setBackgroundColor:color];
//    
//
//    //[colorCodes setValue:[color hexStringFromColor] forKey:@"hexCode"];
//    //[colorCodes setValue:[[NSDictionary alloc] initWithDictionary:[color cmykValues]] forKey:@"cmykCode"];
//    
//    UIColor *testColor = [UIColor colorWithRed:0.53 green:0.37 blue:0.11 alpha:1.00];
//    
//    CGFloat hue;
//    CGFloat saturation;
//    CGFloat brightness;
//    CGFloat alpha;
//    BOOL success = [testColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
//    
//    if (success) {
//        NSDictionary *hsbDic=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%0.2f",hue],@"h",[NSString stringWithFormat:@"%0.2f",saturation],@"s",[NSString stringWithFormat:@"%0.2f",brightness],@"b",[NSString stringWithFormat:@"%0.2f",alpha],@"alpha", nil];
//        [colorCodes setValue:hsbDic forKey:@"hsbCode"];
//    }
//    
//    NSLog(@"colorOfPoint: red: %i : green: %i : blue: %i", pixel[0], pixel[1], pixel[2]);
//    
//    int redInt = [[NSString stringWithFormat:@"%i",pixel[0]] intValue];
//    int greenInt = [[NSString stringWithFormat:@"%i",pixel[1]] intValue];
//    int blueInt = [[NSString stringWithFormat:@"%i",pixel[2]] intValue];
//    
//    NSString *colorHex;
//    colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
//    NSLog(@"colorOfPoint: colorHex: %@", colorHex);
//    
//    [self sendSingleColor:colorHex];
//    
//    return colorCodes;
}

-(void)sendSingleColor :(NSString*) colorHex
{

    NSString *lwdpPacket = [utils createLwdpPacket:@"11" :colorHex];  //Using LWDPr - Light Weight Data Protocol Reduced
    NSLog(@"off: lwdpPacket: %@", lwdpPacket);

    //self.redValue.text = @"255";
    //self.greenValue.text = @"255";
    //self.blueValue.text = @"255";

    [conn sendPacket:lwdpPacket];

}

@end
