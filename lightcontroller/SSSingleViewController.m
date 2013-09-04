//
//  SSSecondViewController.m
//  lightcontroller
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "SSSingleViewController.h"
#import "SSColorSetting.h"
#import "SSUtilities.h"

@interface SSSingleViewController ()

@end

@implementation SSSingleViewController

@synthesize allOnButton;
@synthesize offButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    CGSize size = self.view.bounds.size;
    
    CGSize wheelSize = CGSizeMake(size.width * .85, size.width * .85);
    
    _colorWheel = [[SSColorWheel alloc] initWithFrame:CGRectMake(size.width / 4.8 - wheelSize.width / 6.35,
                                                                  size.height * .16,
                                                                  wheelSize.width,
                                                                  wheelSize.height)];
    _colorWheel.delegate = self;
    _colorWheel.continuous = true;
    [self.view addSubview:_colorWheel];   
    
    _brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(size.width * .45,
                                                                   size.height * .78,
                                                                   size.width * .4,
                                                                   size.height * .1)];
    
    _brightnessSlider.minimumValue = 0.0;
    _brightnessSlider.maximumValue = 1.0;
    _brightnessSlider.value = 1.0;
    [_brightnessSlider addTarget:self action:@selector(changeBrightness:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_brightnessSlider];
    
    
    _wellView = [[UIView alloc] initWithFrame:CGRectMake(size.width * .1,
                                                         size.height * .78,
                                                         size.width * .2,
                                                         size.height * .1)];
    
    _wellView.layer.borderColor = [UIColor blackColor].CGColor;
    _wellView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    _wellView.layer.borderWidth = 1.5;
    _wellView.layer.cornerRadius = 8;
    [self.view addSubview:_wellView];

    
    _redValue.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _redValue.layer.borderWidth = 1.5;
    _redValue.layer.cornerRadius = 8;
    
    _greenValue.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _greenValue.layer.borderWidth = 1.5;
    _greenValue.layer.cornerRadius = 8;
    
    _blueValue.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _blueValue.layer.borderWidth = 1.5;
    _blueValue.layer.cornerRadius = 8;
    
    ///////////////////////////////////////
    conn = [[SSConnection alloc] init];
    utils = [[SSUtilities alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)colorWheelDidChangeColor:(SSColorWheel *)colorWheel
{
    [_wellView setBackgroundColor:_colorWheel.currentColor];
    self.redValue.text = [NSString stringWithFormat:@"%0.0f", _colorWheel.redValue];
    self.greenValue.text = [NSString stringWithFormat:@"%0.0f", _colorWheel.greenValue];
    self.blueValue.text = [NSString stringWithFormat:@"%0.0f", _colorWheel.blueValue];
    
    NSString *colorHex = @"FFFFFF";
    
    int redInt = (int) _colorWheel.redValue;
    int greenInt = (int) _colorWheel.greenValue;
    int blueInt = (int) _colorWheel.blueValue;

    colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
    NSString *lwdpPacket = [utils createLwdpPacket:@"00" :colorHex];
    NSLog(@"colorWheelDidChangeColor: lwdpPacket: %@", lwdpPacket);
    
    [conn sendPacket:lwdpPacket];
}

- (void)changeBrightness:(UISlider*)sender
{
    [_colorWheel setBrightness:_brightnessSlider.value];
    [_colorWheel updateImage];
    [_wellView setBackgroundColor:_colorWheel.currentColor];
    
    NSLog(@"slider value = %f", sender.value);


    [_wellView setBackgroundColor:_colorWheel.currentColor];
    self.redValue.text = [NSString stringWithFormat:@"%0.0f", _colorWheel.redValue];
    self.greenValue.text = [NSString stringWithFormat:@"%0.0f", _colorWheel.greenValue];
    self.blueValue.text = [NSString stringWithFormat:@"%0.0f", _colorWheel.blueValue];

    NSString *colorHex = @"FFFFFF";

    int redInt = (int) _colorWheel.redValue;
    int greenInt = (int) _colorWheel.greenValue;
    int blueInt = (int) _colorWheel.blueValue;

    colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
    NSString *lwdpPacket = [utils createLwdpPacket:@"00" :colorHex];
    NSLog(@"changeBrightness: lwdpPacket: %@", lwdpPacket);
    
    [conn sendPacket:lwdpPacket];
}

- (IBAction)off:(id)sender
{
    NSString *colorHex = @"000000";
    NSString *lwdpPacket = [utils createLwdpPacket:@"00" :colorHex];
    NSLog(@"off: lwdpPacket: %@", lwdpPacket);
    
    self.redValue.text = @"0";
    self.greenValue.text = @"0";
    self.blueValue.text = @"0";
    
    [conn sendPacket:lwdpPacket];
}

- (IBAction)allOn:(id)sender;
{
    NSString *colorHex = @"FFFFFF";
    NSString *lwdpPacket = [utils createLwdpPacket:@"00" :colorHex];
    NSLog(@"off: lwdpPacket: %@", lwdpPacket);
    
    self.redValue.text = @"255";
    self.greenValue.text = @"255";
    self.blueValue.text = @"255";
    
    [conn sendPacket:lwdpPacket];
    
}

//- (void)thisView:(UIView *)thisView did 

//tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//[UIView beginAnimations:nil context:nil];
//[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:detailViewController.mainView cache:YES];
//[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//[UIView setAnimationDuration:1];
//[UIView commitAnimations];



@end
