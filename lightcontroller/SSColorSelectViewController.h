//
//  SSSecondViewController.h
//  lightcontroller
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSColorWheel.h" 
#import "SSConnection.h"
#import "SSUtilities.h"

@class SSColorSelectViewController;

@protocol SSColorSelectViewControllerDelegate <NSObject,UIGestureRecognizerDelegate>

- (void)colorSelectViewController: (SSColorSelectViewController *)controller setupCellColor:(int)redInt :(int)greenInt :(int)blueInt :(int)selectedIndex;
- (void)colorSelectViewController: (SSColorSelectViewController *)controller removeCellColor:(int)selectedIndex;


@end

@interface SSColorSelectViewController : UIViewController  <NSStreamDelegate>
{
    SSColorWheel*   _colorWheel;
    SSConnection*   conn;
    SSUtilities*    utils;
    
    UISlider*       _brightnessSlider;
    UIView*         _wellView;
    
}

@property (strong, nonatomic) IBOutlet UILabel *redValue;
@property (strong, nonatomic) IBOutlet UILabel *greenValue;
@property (strong, nonatomic) IBOutlet UILabel *blueValue;

@property (nonatomic, weak) id <SSColorSelectViewControllerDelegate> delegate;
@property (nonatomic) int redInt;
@property (nonatomic) int greenInt;
@property (nonatomic) int blueInt;
@property (nonatomic) int selectedIndexReturn;

@property (nonatomic) int selectedIndex;
@property (nonatomic) int redIntForward;
@property (nonatomic) int greenIntForward;
@property (nonatomic) int blueIntForward;

-(void)setForwardValues:(int)redIntForward :(int)greenIntForward :(int)blueIntForward :(int)selectedIndex;

@end




