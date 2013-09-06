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


CGFloat mCurrentScale;
CGFloat mLastScale;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    //Check to see if they have configured an IP Address yet, if not, send them to the config page
    int portNumber = 0;
    SSGlobalSettings *connSettings = [SSGlobalSettings sharedManager];
    NSString *ipAddress = connSettings.ipAddress;
    portNumber = connSettings.portNumber;
    
    if (([ipAddress isEqualToString:@""]) || (portNumber == 0))
    {
        //self.tabBarController.selectedIndex = 4;
        //[self.tabBarController.selectedViewController loadView];
    }
    
    CGSize size = self.view.bounds.size;
    
    CGSize wheelSize = CGSizeMake(size.width * .85, size.width * .85);
    
    _colorWheel = [[SSColorWheel alloc] initWithFrame:CGRectMake(size.width / 4.8 - wheelSize.width / 6.35,
                                                                  size.height * .16,
                                                                  wheelSize.width,
                                                                  wheelSize.height)];
    _colorWheel.delegate = self;
    _colorWheel.continuous = true;
    
    [self.view  addSubview:_colorWheel];
    
    [self.view sendSubviewToBack:_colorWheel];
    
    UIPinchGestureRecognizer *zoomColorWheel = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomColorWheel:)];
    UIPanGestureRecognizer *panColorWheel = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panColorWheel:)];
    UITapGestureRecognizer *doubleTapColorWheel = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(doubleTapColorWheel:)];
    
    zoomColorWheel.delegate = self;
    panColorWheel.delegate = self;
    doubleTapColorWheel.delegate = self;
    
    panColorWheel.minimumNumberOfTouches = 2;
    doubleTapColorWheel.numberOfTapsRequired = 2;
    
    [_colorWheel addGestureRecognizer:zoomColorWheel];
    [_colorWheel addGestureRecognizer:panColorWheel];
    [_colorWheel addGestureRecognizer:doubleTapColorWheel];
    
    
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

-(IBAction)zoomColorWheel:(UIPinchGestureRecognizer*)sender
{
    mCurrentScale += [sender scale] - mLastScale;
    mLastScale = [sender scale];
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        mLastScale = 1.0;
    }
    
    if (mCurrentScale < 0.75)
    {
        mCurrentScale = 0.75;
    }
    if (mCurrentScale > 5)
    {
        mCurrentScale = 5;
    }
    
    CGAffineTransform currentTransform = CGAffineTransformIdentity;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, mCurrentScale, mCurrentScale);
    _colorWheel.transform = newTransform;
}

-(IBAction)panColorWheel:(UIPanGestureRecognizer*) sender
{
    CGPoint translation = [sender translationInView:self.view];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
}

-(IBAction)doubleTapColorWheel:(UITapGestureRecognizer*)sender
{
    if (mCurrentScale != 1)
    {
    [UIView animateWithDuration:0.5 animations:^
        {
        _colorWheel.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        _colorWheel.transform = CGAffineTransformIdentity;
        }];
        mCurrentScale = 1;
    }
    else
    {
        CGPoint tapPoint = [sender locationInView:_colorWheel];
        int tapX = (int) tapPoint.x;
        int tapY = (int) tapPoint.y;
        
        CGRect zoomRect = [self zoomRectForScale:4
                                      withCenter:[sender locationInView:_colorWheel]];
        CGFloat s = 4;
        CGAffineTransform tr = CGAffineTransformScale(_colorWheel.transform, s, s);
        //CGFloat h = _colorWheel.frame.size.height;
        //CGFloat w = _colorWheel.frame.size.width;
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            _colorWheel.transform = tr;
            _colorWheel.center = CGPointMake(50,220);  //zoomRect.origin.y,zoomRect.origin.x);
        } completion:^(BOOL finished) {}];


        NSLog(@"TAPPED X:%d Y:%d", tapX, tapY);
        NSLog(@"x: %0.0f: y: %0.0f",zoomRect.origin.x,zoomRect.origin.y );
        
        mCurrentScale = 4;
    }

}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = [_colorWheel frame].size.height / scale;
    zoomRect.size.width  = [_colorWheel frame].size.width  / scale;
    
    center = [_colorWheel convertPoint:center fromView:_colorWheel];
    
    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}



-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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
    NSString *lwdpPacket = [utils createLwdpPacket:@"11" :colorHex];  //Using LWDPr - Light Weight Data Protocol Reduced in the color wheel.
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
    NSString *lwdpPacket = [utils createLwdpPacket:@"11" :colorHex];
    NSLog(@"changeBrightness: lwdpPacket: %@", lwdpPacket);
    
    [conn sendPacket:lwdpPacket];
}

- (IBAction)off:(id)sender
{
    NSString *colorHex = @"000000";
    NSString *lwdpPacket = [utils createLwdpPacket:@"11" :colorHex];
    NSLog(@"off: lwdpPacket: %@", lwdpPacket);
    
    self.redValue.text = @"0";
    self.greenValue.text = @"0";
    self.blueValue.text = @"0";
    
    [conn sendPacket:lwdpPacket];
}

- (IBAction)allOn:(id)sender;
{
    NSString *colorHex = @"FFFFFF";
    NSString *lwdpPacket = [utils createLwdpPacket:@"11" :colorHex];
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
